#!/bin/bash

gen_root_cert(){
	printf "\nWe now will generate a private Elliptic Curve Digital Signature Algorithm (ECDSA) key, in one of the best curves, in human readable format (called PEM). This ECDSA key, with this curve, is the one recommended by Mozilla for modern server security.\n"

	key="del-cakey.pem"
	if openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out \
		private/$key ; then
		echo "ECDSA key generation: DONE. It is named 'cakey.pem'"
	else
		echo ERROR: ECDSA key generation failed, exiting...
		exit "$SSL_ERROR"
	fi
	sleep .5

	printf "\n--------------------------------------------------------------------------------\n"
		
	printf "\nNext, let's change the format to PKCS#8 format, which is the standard. It will prompt you for (1) sudo password --because of access contorls--, and a passphrase. The passphrase is needed for encrypting the key. This way, we add a second layer of security. Make sure to memorize it, or use a password manager such as Proton Pass.\n"
	
	if sudo openssl pkcs8 -topk8 -inform PEM -outform PEM -in private/$key -out \
		private/cakey.pem -v2 aes128 ; then 
		echo "Format changing: DONE"
	else
		echo ERROR: could not change the format, exiting...
		exit "$SSL_ERROR"
	fi
	sleep .5

	printf "\n--------------------------------------------------------------------------------\n"

	printf "\nDeleting old, unencrypted private key so that it cannot be recovered..."
	# shred will make sure that the file is unrecoverable
	if shred -n 10 -u private/$key ; then
		echo "DONE"
	else
		echo "ERROR: key deletion failed. You MUST delete it (preferably, using shred)"...
		exit "$UNKNOWN_ERROR"
	fi
	sleep .5

	key="cakey.pem"

	printf "\n--------------------------------------------------------------------------------\n"

	printf "\nSetting access controls to the key..."
	if sudo chmod 400 private/$key ; then
		echo "DONE. Next, you must set the right owner to the key."
	else
		echo ERROR: could not set access controls. You MUST set them later on...
	fi
	sleep .5

	printf "\n--------------------------------------------------------------------------------\n"

	printf "\nBefore we create the certificate, let's set the Certificate Revocation List (CRL) Distribution Point, which is the point you'll use to distribute the CRL. Other's will use it to verify that a cert signed by you is not revoked. WARNING: Once it is set, you cannot change it. NOTE: the crl is currently named 'crl.pem', located in the current directory (./).\n"
	
	read -rp "\nEnter the CRL distribution point URI, [ e.g., https://crl.example-root-ca.com/crl.pem ] :: " crldp
	if sed -i "/\[ v3_ca \]/a\\crlDistributionPoints = URI:$crldp" openssl.cnf ; then
		echo "DONE"
	else
		echo ERROR: could not write, exiting...
		exit "$FILE_WRITE_ERROR"
	fi
	sleep .5

	printf "\n--------------------------------------------------------------------------------\n\n"

	echo "Now, we will create a self-signed cert for our CA, in X.509 format, that lasts 10 years, with SHA2-512. This will use your private key, so it will prompt you for the passphrase."

	if sudo openssl req -config openssl.cnf -key private/$key -new -x509 -days \
		3650 -sha512 -extensions v3_ca -out ./cacert.pem ; then 
		echo DONE
	else
		echo ERROR: could not create the self-signed certificate, exiting...
		exit "$SSL_ERROR"
	fi
	sleep .5
	
	printf "Setting access controls..."
	if sudo chmod 444 cacert.pem ; then
		echo DONE
	else
		echo "ERROR: could not set access controls, you MUST set them on your own (444)"
	fi
	sleep .5

	echo "The cert is now accessible by anyone to read."
	
	printf "\n--------------------------------------------------------------------------------\n\n"

	printf "Creating a DER copy of the certificate..."
	if openssl x509 -outform der -in cacert.pem -out cacert.der ; then
		echo DONE
	else
		echo ERROR: could not create a DER copy of the certificate. Proceeding...
	fi
	sleep .5

	printf "\n--------------------------------------------------------------------------------\n\n"

	printf "Creating a RANDFILE of random bytes for the OpenSSL seeding..."
	if dd if=/dev/urandom of=randfile bs=256 count=1 ; then
		echo DONE.
	else
		echo ERROR: could not create the RANDFILE. Please do so yourself.
	fi

	printf "\n--------------------------------------------------------------------------------\n\n"

	echo "Done! Your cert is now ready to be used!"
}