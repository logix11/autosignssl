#!/bin/bash

cert_revoke(){
	echo "Select the certificate."

	certs=(private/*)
	echo "[-1] Exit"
	for i in "${!certs[@]}" ; do
		echo "[$i] ${certs[i]}"
	done

	while : ; do
		read -rp "Your input :: " choice

		if [[ $choice = "-1" ]] ; then
			echo "Exiting..."
			return 0

		elif [[ $choice > $i ]] ; then 
			echo "Invalid choice. Try again"

		else
			printf Revoking...
			cert=${certs[$choice]}
			if sudo openssl ca -config openssl.cnf -revoke certs/"$cert" ; then
				echo DONE.

			else
				echo ERROR, could not revoke the certificate.
				return 0
			fi

			printf "Refreching the CRL..."
			if sudo openssl ca -config openssl.cnf -gencrl -out crl.pem	; then
			echo
				echo DONE.
				return 0
			else
				echo ERROR, could not refresh the CRL...
				return 0
			fi
		fi
	done
}