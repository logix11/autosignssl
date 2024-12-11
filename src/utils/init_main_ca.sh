#!/bin/bash

# Importing files
source "./utils/ca_setup.sh"

main_init_ca(){
	printf "Before we proceed, make sure that this script is running in the right location. Everything that we will create will be a sub-directory/sub-files of this directory. Proceed? [Y/n] :: "
	
	while : ; do
		read -r choice
		if [[ $choice == "n" || $choice == "N" ]] ; then # Wrong directory
			echo "Wrong directory, exiting..."
			exit "$DIR_INIT_ERROR"

		elif [[ $choice = "y" || $choice = "Y" ]] ; then # Correct directory
			break
			
		else # right directory
			printf "Invalid input. Try again :: "

		fi

	done
	echo "Greate! Let's keep going"

	printf "\n--------------------------------------------------------------------------------\n"

	read -rp "Choose a name for your local root CA :: " name

	echo "Greate name!"
	sleep .5

	printf "\n--------------------------------------------------------------------------------\n"
	
	echo "Initializing.."
	initialize "$name"

	printf "\n--------------------------------------------------------------------------------\n\n"

	echo "Users must now deliver their CSR to your csr/. From there, you can sign them."
}