#!/bin/bash

csr_gen(){
	echo; echo "Select the private key."
	local keys; local i; local choice; 
	keys=($(sudo ls private/*)) # List the items and store them in the variable	
	echo "	[-1] Exit"
	for i in "${!keys[@]}"; do
		echo "	[$i] ${keys[i]}"
	done

	
	while : ; do
		echo
		read -rp "	Your input :: " choice
		if [[ $choice = "-1" ]] ; then
			echo -e "$WARNING	Exiting .."
			return 0
		elif [[ $choice > $i ]] ; then # Bash allows you to sum integers with 
									  # strings :)
			echo -e "$WARNING	Invalid choice."
		else
			if openssl req -config openssl.cnf -outform PEM -out \
					csr/new.pem -new -key "${keys[choice]}" -sha512 
			then
				echo -e "${INFO}	Certificate signing request was generated successfully. You should rush to change its name"
				return 0
			else
				echo -e "${ERROR}, the certificate signing request generation was unseccessful."
			fi
		fi
	done
}