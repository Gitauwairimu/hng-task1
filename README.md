# User Management Script (user_manage.sh) - README

This README provides information about user_manage.sh, a Bash script designed to automate user creation and group management. This is towards fulfilment of the HNG Internship Program in which am taking part in the DevOps track.

## Prerequisites
- A modest knowledge of linux is required.
- Access to Ubuntu linux system and its sudo privileges.
- A text file with rows that contain user and groups they belong to, seperated by a semi-colon.

Below is an example of the text file contents;
    light; sudo,dev,www-data
    idimma; sudo
    mayowa; dev,www-data


## Functionality

The script automates user management tasks by processing a file containing user information (username and groups separated by semicolon).

 Here's a breakdown of its actions for each user:

## User Creation: Creates the user if it doesn't already exist (using sudo useradd).
## Password Generation:

   - Generates a random password using /dev/urandom.
   - Assigns the password to the user with sudo chpasswd. (Security Concern: See below for important security information)

## Group Management (Currently Disabled):

    (This functionality is commented out in the script)
       - Creates any missing groups specified for the user (using sudo groupadd).
       - Adds the user to each specified group (using sudo usermod -aG).

## Logging: Records actions with timestamps in a log file (/var/log/user_management.log).


Important Security Consideration

This script has a critical security flaw: it stores usernames and passwords in plain text within /var/secure/user_passwords.cvs. This poses a significant risk if someone gains access to the file.
Recommendations

Here are some recommendations to improve the script's security:

    Secure Password Management: Implement secure password storage methods like password managers or shadow passwords. These solutions encrypt passwords or store one-way hashes, making them difficult to crack.
    Avoid Plain Text Logging: Consider logging only usernames and non-sensitive information in the log file.
    Minimize sudo Usage: Explore alternative approaches that reduce reliance on sudo.
    Input Validation: Implement input validation to ensure the script processes correctly formatted user data files.

How to Use

    Save the Script: Save the script as user_manage.sh.
    Make it Executable: Grant the script execution permission using chmod +x user_manage.sh.
    Run the Script: Execute the script with the path to your user data file as an argument: ./user_manage.sh /path/to/user_data.txt.

Note: Due to the security concern mentioned above, it's strongly recommended to modify the script to avoid storing passwords in plain text. Consider using a password manager or alternative secure password storage methods.
