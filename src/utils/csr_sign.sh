#!/bin/bash

csr_sign(){
	echo Select the CSR.
	local csrs; local i; local choice; local ext;
	csrs=(csr/*) # List the items and store them in the variable
	echo "	[-1] Exit"
	for i in "${!csrs[@]}"; do
		echo "	[$i] ${csrs[i]}"
	done

	while : ; do
		read -rp "	Your choice :: " choice
		if [[ $choice = "-1" ]] ; then
			echo -e "$WARNING Exiting..."
			return 0

		elif [[ $choice > $i || -z $choice ]] ; then # Bash allows you to sum integers with strings :)
			echo -e "$WARNING Invalid choice."

		else
			echo ; echo "	Add extensions. The initiating script stamps profiles with a mark to distinguish them. If you have created other profiles, this script will be incapable of detecting them unless they're stamped as others are. To stamp them, simply add '# profile' after the directive."; echo
			if grep "# profile" openssl.cnf ; then
				echo
			else
				echo -e "$ERROR Could not show extensions..."
			fi
			break
		fi
	done

	read -rp "	Your input (Leave blank to skip) :: "

	if [[ -z $ext ]] ; then
		if sudo openssl ca -config openssl.cnf -notext \
		-in "${csrs[choice]}" -out certs/newcert.cert ; then
			echo -e "$INFO	DONE."
		else
			echo -e "$ERROR	There was an error."
		fi
	else
		if sudo openssl ca -config openssl.cnf -notext -extensions "$ext" \
			-in "${csrs[choice]}" -out certs/newcert.cert ; then
			echo -e "$INFO	DONE."
			read -rp "	Will this certificate be used for the typical SSL protocol, or will it be used for S/MIME email encryption protocol? (typ/smime):: " smime
			if [[ $smime = "smime" ]] ; then
				echo; echo "	Select the private key that'll be assigned to this certificate."
				local keys; local i; local choice;
				keys=(private/*)
				for i in "${!keys[@]}"; do
					echo "	[$i] ${keys[i]}"
				done
				read -rp "	Your input :: " choice
				if [[ $choice > $i || -z $choice ]] ; then
					echo -e "$WARNING	Invalid choice."
				else

					read -rp "	Enter the username you wish to display with this key :: " username
					if sudo openssl pkcs12 -export -inkey "${keys[choice]}" -in certs/newcert.cert \
						-certfile cacert.pem -out certs/newcert.p12 -name "$username"
					then
						echo "PKCS#12 File format generated successfully. This file contains (1) the certificate; (2) the private key; and (3) the CA's certificate. Be careful when sharing this file"
						return 0
					else
						echo "PKCS#12 File format generation failed"
						return 1
					fi
				fi
			elif [[ $smime = "typ" ]] ; then
				return 0
			else
				echo "Invalid input"
			fi

		else
			echo -e "$ERROR	There was an error."
		fi
	fi
}
