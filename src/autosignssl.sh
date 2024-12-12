#!/bin/bash

# Exit codes
SSL_ERROR=1
PATH_ERROR=2
DIR_INIT_ERROR=3
CD_ERROR=4
PERMS_ERROR=5
FILE_WRITE_ERROR=6
CP_ERROR=7
UNKNOWN_ERROR=8

# Importing files
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source $SCRIPT_DIR/utils/init_main_ca.sh
source $SCRIPT_DIR/utils/cert_man.sh

# Define color variables
BLUE='\033[97;44m'      # Dark Blue background, white text
RED='\033[41m'       # Red background
YELLOW='\033[48;5;214m' # Yellow background, dark text
RESET='\033[0m'      # Reset to default


INFO="${BLUE}[ INFO ]${RESET}"
ERROR="${RED}[ ERROR ]${RESET}"
WARNING="${YELLOW}[ WARNING ]${RESET}"
echo "
   _____          __          _________.__                _________ _________.____  
  /  _  \  __ ___/  |_  ____ /   _____/|__| ____   ____  /   _____//   _____/|    |
 /  /_\  \|  |  \   __\\/  _ \\______  \ |  |/ ___\ /    \ \\_____  \ \\_____  \\ |    |
/    |    \  |  /|  | (  <_> )        \|  / /_/  >   |  \/        \/        \|    |___
\____|__  /____/ |__|  \____/_______  /|__\___  /|___|  /_______  /_______  /|_______ \\
        \/                          \/   /_____/      \/        \/        \/         \/

-------------------------------Hello and welcome!-------------------------------

This program will help you establish a local, root SSL Certificate Authority (CA) and manage it.

You can do the following

	[*] Create a local root CA;
	[*] Generate keys;
	[*] Generate certificate signing requests (CSRs);
	[*] Sign on certificates;
	[*] Verify certificates;
	[*] Revoke certificates

Let us get started, shall we?"

echo -e "$INFO	Ensuring that OpenSSL is installed before running this script..."
sleep .5

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null
then
	echo -e "${ERROR}	No OpenSSL, exiting..."
	exit $SSL_ERROR
fi

echo -e "${INFO}	DONE, it is indeed installed."
sleep .5

while :
do
	
	printf "\n--------------------------------------------------------------------------------\n\n"

	echo "Select an option.
	[0] Exit.
	[1] Establish the CA.
	[2] Manage the CA"
	echo
	read -rp "	Your input :: " choice
	if [[ $choice == "0" ]]
	then
		echo -e "$WARNING	Exiting..."
		exit 0
	elif [[ $choice == "1" ]]
	then
		main_init_ca
	elif [[ $choice == "2" ]]
	then
		cert_man
	else
		echo -e "${ERROR}	Invalid input."		
	fi
done