#!/bin/bash

csr_sign(){
	echo Select the certificate.

	csrs=(csr/*) # List the items and store them in the variable	
	echo "	[-1] Exit"
	for i in "${!csrs[@]}"; do
		echo "	[$i] ${csrs[i]}"
	done

	printf "Your input :: "
	while : ; do
		read -r choice
		if [[ $choice = "-1" ]] ; then
			echo "Exiting .."
			return 0

		elif [[ $choice > $i ]] ; then # Bash allows you to sum integers with 
									  # strings :)
			printf "Invalid choice. Try again :: "

		else
			printf "\nAdd extensions. The initiating script stamps profiles with a mark to distinguish them. If you have created other profiles, this script will be incapable of detecting them unless they're stamped as others are. To stamp them, simply add '# profile' after the directive.\r\n"
			if grep "# profile" openssl.cnf ; then
				echo
			else
				echo -e "$ERROR	Could not show extensions..."
				return 0
			fi
			break	
		fi
	done
	printf "Your input :: "
	read -r ext
	
	if sudo openssl ca -config openssl.cnf -notext -extensions "$ext" -in \
		"${csrs[choice]}" -out certs/newcert.cert ; then
		echo -e "$INFO	The certificate was signed successfully."
	else
		echo -e "$ERROR	There was an error while signing the certificate."
	fi
}