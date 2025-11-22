#!/bin/bash

pkey_gen(){
	local choice;
	echo; echo "Select a key to create.
	[1] RSA key (discouraged).
	[2] Elliptic Curve parameters (for ECDSA/ECDH).
	[0] Exit"
	while : ; do
		echo
		read -rp "	Your input :: " choice
		if [[ $choice == 0 ]] ; then
			echo -e "$WARNING Exiting..."
			return 0

		elif [[ $choice == 1 ]] ; then
			if openssl genpkey -algorithm RSA -out private/kpriv_rsa.pem -pkeyopt \
				rsa_keygen_bits:3072 -outform PEM ; then
				echo -e "${INFO} Private key generation was done successfully. The key is called kpriv_rsa.pem"
			else
				echo -e "${ERROR} Could not generate the RSA key."
			fi
			return 0

		elif [[ $choice == 2 ]] ; then
			if openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 \
				-out private/kpriv_ec.pem -outform PEM ; then
				echo -e "${INFO} Private key generation was done successfully. key is called kpriv_ec.pem"
			else
				echo -e "${ERROR} Could not generate the RSA key."
			fi
			return 0
		else
			echo -e "$WARNING Invalid input."
		fi
	done
}
