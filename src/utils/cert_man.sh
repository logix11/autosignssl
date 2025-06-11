#!/bin/bash

source "$SCRIPT_DIR/utils/pkey_gen.sh"
source "$SCRIPT_DIR/utils/csr_gen.sh"
source "$SCRIPT_DIR/utils/csr_sign.sh"
source "$SCRIPT_DIR/utils/cert_verif.sh"
source "$SCRIPT_DIR/utils/cert_print.sh"
source "$SCRIPT_DIR/utils/cert_revoke.sh"

cert_man(){
	local condition; local path
	echo; echo -e "$WARNNIG	This script must be running in the CA's home directory, i.e., in the sshca/ directory that was created earlier. If this condition is not satisfied, then you must guide the program to find that directory."
	while :
	do
		read -rp "Is the current directory it? [Y/n] " condition
		if [[ $condition == "n" || $condition == "N" ]]
		then
			while :
			do
				read -rp "Enter the path to the directory (or leave blank to exit) :: " path
				if [[ -z $path ]]
				then
					echo -e "$WARNING	Exiting..."
					exit 0
				elif cd "./$path"
				then
					echo -e "$INFO	Moved to the directory"
					break
				else
					echo -e "$WARNING	Invalid path."
				fi
			done
			break
		elif [[ $condition == "y" || $condition == "Y" ]]
		then
			echo Good job.
			break
		else
			echo -e "$WARNING	Invalid input"
		fi
	done
	echo -e "$INFO	Proceeding..."

	echo "Select an option"
	local choice
	while : ; do
		echo "	[0] Exit.
	[1] Generate a private key.
	[2] Generate a CSR.
	[3] Sign a cert.
	[4] Verify a cert.
	[5] Revoke a cert.
	[6] Print out a cert."

		echo
		read -rp "	Your input :: " choice
		if [[ $choice = 0 ]] ; then
			echo -e "$WARNING Exiting..."
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
		elif [[ $choice = 7 ]] ; then
			echo "This feature is not yet implemented, try again later."
		else
			echo -e "$WARNING	Invalid input."
		fi
	done
}