#!/bin/bash

# Importing files
source "$SCRIPT_DIR/utils/ca_setup.sh"

main_init_ca(){
	echo -e "$WARNING Before we proceed, make sure that this script is running in the right location. Everything that we will create will be a sub-directory/sub-files of this directory."

	local choice; local name;
	while : ; do
		read -rp "Proceed? [Y/n] :: " choice
		if [[ $choice == "n" || $choice == "N" ]] ; then # Wrong directory
			echo -e "$WARNING	Wrong directory, exiting..."
			exit "$DIR_INIT_ERROR"

		elif [[ $choice = "y" || $choice = "Y" ]] ; then # Correct directory
			break
			
		else # right directory
			echo -e "$WARNING	Invalid input."
		fi

	done
	echo -e "$INFO	Greate! Let's keep going"

	printf "\n--------------------------------------------------------------------------------\n\n"

	read -rp "Choose a name for your local root CA :: " name

	printf "\n--------------------------------------------------------------------------------\n\n"
	
	echo -e "$INFO	Initializing.."
	initialize "$name"
	
	printf "\n--------------------------------------------------------------------------------\n\n"

	echo -e "$INFO	Users must now deliver their CSR to your csr/. From there, you can sign them."
}