#!/bin/bash

pkey_gen(){
	printf "Select a key to create.
	[1] RSA key (discouraged).
	[2] Elliptic Curve parameters (for ECDSA/ECDH).
	[0] Exit
	
	Your input :: "
	while : ; do
		read -r choice
		if [[ $choice == 0 ]] ; then
			echo Exiting...
			return 0
		
		elif [[ $choice == 1 ]] ; then
			if openssl genpkey -algorithm RSA -out private/kpriv_rsa.pem -pkeyopt \
				rsa_keygen_bits:3072 -outform PEM ; then
				echo -e "${INFO}	Private key generation was done successfully."
				echo -e "${INFO}	The key is called kpriv_rsa.pem"
			else
				echo -e "${ERROR}	Could not generate the RSA key."
			fi
			return 0
		
		elif [[ $choice == 2 ]] ; then
			if openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 \
				-out private/kpriv_ec.pem -outform PEM ; then
				echo -e "${INFO}	Private key generation was done successfully."
				echo -e "${INFO}	The key is called kpriv_ec.pem"
			else
				echo -E "${ERROR}	Could not generate the RSA key."
			fi
			return 0
		else
			printf "Invalid input. Try again :: "
		fi
	done
}