#!/bin/bash

cert_verif(){
	echo "Select the certificate."
	local certs; local i; local choice; 
	certs=(certs/*)
	echo "	[-1] Exit"
	for i in "${!certs[@]}"; do
		echo "	[$i] ${certs[i]}"
	done

	while : ; do
		echo
		read -rp "	Your input :: " choice
		if [[ $choice = "-1" ]] ; then
			echo -e "$WARNING	Exiting..."
			return 0
		elif [[ $choice > $i ]] ; then # Bash allows you to sum integers with 
									  # strings :)
			echo -e "$WARNING	Invalid choice."
		else
			if openssl verify -crl_check -CRLfile ./crl.pem -CAfile ./cacert.pem \
				"${certs[choice]}"; then
				echo
			else
				echo -e "$ERROR	Could not verify the certificate."
			fi
			break	
		fi
	done
}