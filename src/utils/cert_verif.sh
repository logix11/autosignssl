#!/bin/bash

cert_verif(){
	echo "Select the certificate."
	
	certs=(certs/*)
	echo "[-1] Exit"
	for i in "${!certs[@]}"; do
		echo "[$i] ${certs[i]}"
	done

	while : ; do
		read -rp "Your input :: " choice
		if [[ $choice = "-1" ]] ; then
			echo "Exiting .."
			return 0
		elif [[ $choice > $i ]] ; then # Bash allows you to sum integers with 
									  # strings :)
			echo "Invalid choice. Try again"
		else
			if openssl verify -crl_check -CRLfile ./crl.pem -CAfile ./cacert.pem \
				"${certs[choice]}"; then
				echo
			else
				echo ERROR, could not verify the certificate due to an unknown error
			fi
			break	
		fi
	done
}