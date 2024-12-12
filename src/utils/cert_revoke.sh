#!/bin/bash

cert_revoke(){
	echo "Select the certificate."

	certs=(certs/*)
	echo "	[-1] Exit"
	for i in "	${!certs[@]}" ; do
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
			if sudo openssl ca -config openssl.cnf -revoke "$cert" ; then
				echo -e "$INFO	The certificate was revoked successfully."

			else
				echo -e "$ERROR	Could not revoke the certificate."
				return 0
			fi

			printf "Refreching the CRL..."
			if sudo openssl ca -config openssl.cnf -gencrl -out crl.pem	; then
			echo
				echo -e "$INFO	The CRL was refreshed successfully."
				return 0
			else
				echo -e "$ERROR	Could not refresh the CRL."
				return 0
			fi
		fi
	done
}