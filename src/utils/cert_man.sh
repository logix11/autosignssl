#!/bin/bash

source "./utils/pkey_gen.sh"
source "./utils/csr_gen.sh"
source "./utils/csr_sign.sh"
source "./utils/cert_verif.sh"
source "./utils/cert_print.sh"
source "./utils/cert_revoke.sh"

cert_man(){
	local condition
	printf "\nThis script must be running in the SSH CA's home directory, i.e., in the sshca/ directory that was created earlier. If this condition is not satisfied, then you must guide the program to find that directory. Is the current directory it? [Y/n] "
	while :
	do
		read -r condition
		if [[ $condition == "n" || $condition == "N" ]]
		then
			printf "Enter the path to the directory (or leave blank to exit) :: "
			while :
			do
				read -r path
				if [[ -z $path ]]
				then
					echo Exiting...
					exit 0
				elif cd "$path"
				then
					echo -e "${INFO}	Moved to the sshca/ directory"
					break
				else
					printf "Invalid path. Try again :: "
				fi
			done
			break
		elif [[ $condition == "y" || $condition == "Y" ]]
		then
			echo Good job.
			break
		else
			printf "Invalid input. Try again :: "
		fi
	done
	echo "Proceeding..."

	echo "Select an option"
	while : ; do
		printf "
	[0] Exit.
	[1] Generate a private key.
	[2] Generate a CSR.
	[3] Sign a cert.
	[4] Verify a cert.
	[5] Revoke a cert.
	[6] Print out a cert.
	
	Your input :: "

		read -r choice
		if [[ $choice = 0 ]] ; then
			exit 0
		elif [[ $choice = 1 ]] ; then
			pkey_gen
		elif [[ $choice = 2 ]] ; then
			csr_gen
		elif [[ $choice = 3 ]] ; then
			csr_sign
		elif [[ $choice = 4 ]] ; then
			cert_verif
		elif [[ $choice = 5 ]] ; then
			cert_revoke
		elif [[ $choice = 6 ]] ; then
			cert_print
		else
			echo "Invalid input."
		fi
	done
}