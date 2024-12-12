#!/bin/bash

csr_gen(){
	printf "\nSelect the private key.\n"
	
	keys=($(sudo ls private/*)) # List the items and store them in the variable	
	echo "	[-1] Exit"
	for i in "${!keys[@]}"; do
		echo "	[$i] ${keys[i]}"
	done

	printf "\n	Your input :: "
	while : ; do
		read -r choice
		if [[ $choice = "-1" ]] ; then
			echo "Exiting .."
			return 0
		elif [[ $choice > $i ]] ; then # Bash allows you to sum integers with 
									  # strings :)
			printf "Invalid choice. Try again :: "
		else
			if openssl req -config openssl.cnf -outform PEM -out \
					csr/csr-"new" -new -key "${keys[choice]}" -sha512 
			then
				echo -e "${INFO}	Certificate signing request was generated successfully."
				echo -e "${WARNING}	You should rush to change its name"
				return 0
			else
				echo -e "${ERROR}, the certificate signing request generation was unseccessful."
			fi
		fi
	done
}