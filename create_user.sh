#!/bin/bash

# Check if a filename is provided as argument
if [ $# -eq 0 ]; then
  echo "Error: Please provide the filename of tout.txt as an argument."
  exit 1
fi

# Get the filename from the first argument
tout_file="$1"

log_file="/var/log/user_management.log"
secrets_file="/var/secure/user_passwords.txt"

# Check if log file exists
if [[ ! -f "$log_file" ]]; then
  # Create the log file with touch (or redirect empty output)
  sudo touch "$log_file"  # OR  echo > "$log_file"

fi


sudo chown $USER:$USER /var/log/user_management.log
# Open the log file for appending (>>)
exec &>> "$log_file"

#sudo chown $USER:$USER /var/log/user_management.log

while IFS=';' read -r usrname groups; do

  # Check if line is empty or contains comments (starting with '#')
  if [[ -z "$usrname" || "$usrname" =~ ^# ]]; then
    continue
  fi

  # Print the extracted information
  echo "***************************************************"
  echo "Usrname: $usrname"
  echo "Groups:"

  # Create the user (if doesn't exist)
  sudo useradd "$usrname" &>/dev/null  # Suppress output for user existence check
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Added user $usrname"

  password=$(tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | head -c 10)

  echo "$password"

  echo "$usrname:$password" | sudo chpasswd
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Generated password: $password"
  # Log successful password assignment
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Assigned random password to $usrname"


  sudo mkdir -p /var/secure
  sudo chmod 700 /var/secure
  sudo touch /var/secure/user_passwords.txt
  sudo chmod 660 /var/secure/user_passwords.txt
  sudo chmod u+rw /var/secure/user_passwords.txt
  sudo chown $USER:$USER /var/secure


  user=$(whoami)  # Get the currently logged-in username
  sudo chown "$user:$user" /var/secure/user_passwords.txt  # Change owner and group
  sudo chmod u+rw /var/secure/user_passwords.txt  # Grant read and write permissions to the owner (current user)

  # Write username and password to file using here document (not recommended)
  # Log to a top-secret file
  sudo echo "$usrname:$password" >> "/var/secure/user_passwords.txt"

  # Loop through each group separated by comma
  IFS=',' read -ra group_array <<< "$groups"
  for group in "${group_array[@]}"; do
    # Log group before attempting creation
    #exec &>> "$log_file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Checking group: $group"
    echo "  - $group"

    # Create the group (if doesn't exist)
    sudo groupadd "$group" &>/dev/null  # Suppress output for group existence check
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Created group $group"
    # Add user to the group
    sudo usermod -aG "$group" "$usrname"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Added user $usrname to group $group"

    # Generate a random password
    #password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()_+-=[]{}|;:\',./<>?' | fold -w 12 | head -n 1)
    # Log password generation (not recommended for security)
    # echo "$(date '+%Y-%m-%d %H:%M:%S') - Generated password: $password"  # Security Risk
     
    #echo "$(date '+%Y-%m-%d %H:%M:%S') - Assign password to  $usrname"
    getent group "$group"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Confirm user $usrname is added to group $group"

    # Verify group addition (optional)
    # getent group "$group"
    
  done

  # Reset IFS to its default value
  IFS=' '

done < "$tout_file"

# Script exits here
exit 0
