#!/bin/bash

cert_print(){
	echo; echo "Select the certificate."

	local certs; certs=(certs/*)
	local i;
	echo "	[-1] Exit"
	for i in "${!certs[@]}"; do
		echo "	[$i] ${certs[i]}"
	done
	local choice;
	while : ; do
		echo
		read -rp "	Your input :: " choice
		if [[ $choice = "-1" ]] ; then
			echo -e "$WARNING	Exiting .."
			return 0

		elif [[ $choice > $i ]] ; then 
			echo -e "$WARNING	Invalid choice."

		else
			local cert; cert=${certs[$choice]}
			if openssl x509 -in "$cert" -noout -text ; then
				echo 
			else
				echo -e "$ERROR	Could not print the certificate."
				return 0
			fi		
			break	
		fi
	done
}