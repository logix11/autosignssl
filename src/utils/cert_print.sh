#!/bin/bash

cert_print(){
	echo "Select the certificate."

	certs=(private/*)
	echo "[-1] Exit"
	for i in "${!certs[@]}"; do
		echo "[$i] ${certs[i]}"
	done

	while : ; do
		read -rp "Your input :: " choice
		if [[ $choice = "-1" ]] ; then
			echo "Exiting .."
			return 0

		elif [[ $choice > $i ]] ; then 
			echo "Invalid choice. Try again"

		else
			cert=${certs[$choice]}
			if openssl x509 -in certs/"$cert" -noout -text ; then
				echo 
			else
				echo ERROR, could not print the certificate.
				return 0
			fi		
			break	
		fi
	done
}