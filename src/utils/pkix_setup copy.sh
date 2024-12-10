#!/bin/bash

initialize(){
	# Firstly, we need to create five directories to confront to X.509
	echo "Creating directories..."
	if mkdir -p pkix/"$1"/{certs,crl,csr,newcerts,private} 
	then
		echo DONE.
	else
		echo ERROR: could not create the directories due to an unknown error, exiting...
		exit "$DIR_INIT_ERROR"
	fi

	if cd "pkix/$1"
	then
		echo "Moving to 'pkix/'... DONE"
	else
		echo "ERROR: could not move to 'pkix/', exiting..."
		exit "$CD_ERROR"
	fi

	printf "Setting access controls to 'priate/'..."
	if sudo chmod 700 private/ 
	then
		echo DONE
	else
		echo ERROR: could not set access controls, exiting...
		exit "$PERMS_ERROR"
	fi
	sleep .5

	printf "\n--------------------------------------------------------------------------------"

	printf "\nCopying OpenSSL's configuration file..."

	# Copying OpenSSL's configuration file, preserving some attributes
	if sudo cp --preserve=mode,ownership,timestamps,context,xattr \
		/etc/ssl/openssl.cnf ./openssl.cnf
	then
		echo DONE
	else
		echo ERROR: could not copy openssl.cnf configuration file, exiting...
		exit "$CP_ERROR"
	fi

	echo "We've copied openssl.cnf for no reason other than preserving the configuration file's attributes."
	echo "We'll overwrite it now. We need your privileges. But before that, let's learn more about you!"
	echo "Postscriptum: this knowledge will be used in nothing other than setting your OpenSSL configuration :)"
	
	read -rp "What's your country's two character code? :: " country

	read -rp "What's your state or province's name? :: " state

	read -rp "What's your locality (e.g., city) name? :: " locality
	
	read -rp "What's your organization's name? :: " org

	sudo echo "[ ca ] # How the 'ca' command will act when utilized to sign certs
	default_ca		= ca_default # The name of the default CA section

[ ca_default ] # defining the default CA section
	dir				= /var/ca		# Default root directory
	certs			= \$dir/certsdb	# Default certificates directory
	new_certs_dir	= \$certs		# Default new certificates directory
	database		= \$dir/index.txt	# Database of certificates
	certificate		= \$dir/cacert.pem	# The default CA's certificate
	private_key		= \$dir/private/cakey.pem	# the default CA's private key
	serial			= \$dir/serial		# A database of serials.
	crldir			= \$dir/crl			# Default CRL directory 
	crlnumber		= \$dir/crlnumber	# CRL serial
	crl				= \$crldir/crl.pem	# CRL file.
	RANDFILE		= \$dir/private/.rand	# File of random data, need to set up the script to fill it from the /dev/urandom
	name_opt		= ca_default # How the name is displayed to you for confirmation
	cert_opt		= ca_default # How the certificate is displayed to you for confirmation
	default_days	= 90
	default_crl_days= 30
	default_md		= sha256
	preserve		= no		# Do not allow people to determine the order of their DN.
	policy			= policy_match # Strict policy

[ policy_match ]
	countryName			= match
	stateOrProvinceName	= match
	localityName		= match	# Locality name (e.g., city)
	organizationName	= match	
	organizationalUnitName = optional
	commonName			= supplied
	emailAddress		= optional

[ policy_anything ]
	countryName				= optional
	stateOrProvinceName		= optional
	localityName			= optional
	organizationName		= optional
	organizationalUnitName	= optional
	commonName				= supplied
	emailAddress			= optional

[ req ]	# a section for the req command
	default_bits			= 3072
	default_keyfile			= \dir/privkey.pem
	distinguished_name		= req_distinguished_name # referencing a section
	attributes				= req_attributes  # referencing a section
	x509_extensions			= v3_ca # referencing a section
	req_extensions			= v3_req # referencing a section
	string_mask 			= utf8only

[ req_distinguished_name ]
	countryName				= Country Name (2 letter code)
	countryName_default		= $country
	countryName_min			= 2
	countryName_max			= 2

	stateOrProvinceName		= State or Province Name (full name)
	stateOrProvinceName_default	= $state

	localityName			= Locality Name (eg, city)
	localityName_default	= $locality

	0.organizationName			= Organization Name (eg, company)
	0.organizationName_default	= $org	 

	organizationalUnitName	= Organizational Unit Name (eg, section)

	commonName		= Common Name (eg, YOUR name)
	commonName_max	= 64

	emailAddress    	= Email Address
	emailAddress_max	= 64

[ req_attributes ]
	challengePassword			= A challenge password
	challengePassword_min		= 8
	challengePassword_max		= 20
	
[ v3_req ]

	basicConstraints= CA:FALSE
	keyUsage		= digitalSignature, keyAgreement
	subjectAltName	= email:move

[ ecdsa_polsect ]
	policyIdentifier 	= 1.3.6.1.5.5.7.3.1	# for serverAuth
	userNotice.1 		= @notice

[ ecdsa_polsect ]
	policyIdentifier	= 1.3.6.1.5.5.7.3.1	# for serverAuth too... Couldn't find any better
	userNotice.1		= @notice

[notice]
	explicitText	= 'This CA policy covers the following requirements: Common Name is required, other fields are optional. All certificates must comply with the CA\'s operational standards and policies.'
	organization	= 'Alboutica'
	noticeNumbers	= 1	# I only have one security policy anyway.

[ ca_polsect ]
	policyIdentifier = 1.3.6.1.5.5.7.3.27	# for serverAuth
	userNotice.1 	= @notice

[ v3_ca ]
	subjectKeyIdentifier	= hash
	authorityKeyIdentifier	= keyid:always,issuer:always
	basicConstraints		= critical,CA:true
	subjectAltName			= email:move
	issuerAltName			= email:move
	crlDistributionPoints 	= URI:https://crl.example-root-ca.com/crl.pem
	keyUsage 				= cRLSign, keyCertSign, digitalSignature
	subjectAltName			= email:copy
	certificatePolicies 	= ia5org, @ca_polsect

[ v3_server_kex ] # profile
	basicConstraints		= CA:FALSE 

	authorityKeyIdentifier	= keyid,issuer # the hash of the key
	subjectKeyIdentifier	= hash			
	keyUsage				= keyAgreement, digitalSignature # used for key 
															 # establishment
	subjectAltName	= email:move # moves the email from the DN to the SAN
	issuerAltName	= issuer:move
	extendedKeyUsage= serverAuth # An other usage of the key is to 
		# authenticate the server to the client. I have commented it because 
		# diffie-helmann is not used to authenticate but to establish keys.
	
[ v3_server_sig ] # profile
	basicConstraints		= CA:FALSE
	authorityKeyIdentifier	= keyid,issuer
	subjectKeyIdentifier	= hash
	keyUsage				= digitalSignature, keyEncipherment
	subjectAltName			= email:move
	issuerAltName			= issuer:move
	extendedKeyUsage		= serverAuth" | sudo tee openssl.cnf
##########################
##########################
##########################	
##########################
###	Continue From here ###
##########################
##########################
##########################	
##########################


	echo "
--------------------------------------------------------------------------------
	"

	printf "Creating DB index.txt..."
	touch index.txt
	echo "DONE."

	echo "
--------------------------------------------------------------------------------
	"
	if [ ! -f serial ] ; then
		printf "Creating serial and CRL serial..."
		echo 00 > serial
		echo 00 > crlnumber # If either of them exist, then the other does as 
							# well. I can't imagine a setup with only a serial.
		echo "DONE."
	fi
	echo "
--------------------------------------------------------------------------------
	"

	echo "Evinronment creation: DONE."

	echo "
--------------------------------------------------------------------------------
	" 
	
	printf "Proceeding to root CA generation..."	
	gen_root_cert # Calling function to generate root CA cert
	echo "DONE"

	echo "
--------------------------------------------------------------------------------"
	
	printf "Creating revokation list..."
	sudo openssl ca -config openssl.cnf -gencrl -out crl.pem || exit 1
					# We need root access to the private key.
	echo "DONE"
}

# A function to generate root self-signed certs
gen_root_cert(){
	echo "
We now will generate a private Elliptic Curve Digital Signature Algorithm 
(ECDSA) key, in one of the best curves, in human readable format (called PEM). 
This ECDSA key, with this curve, is the one recommended by Mozilla for modern 
server security."

	key="del-cakey.pem"
	openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out \
	private/$key || exit 1
	echo "ECDSA key generation: DONE. It is named 'cakey.pem'"

	echo "
--------------------------------------------------------------------------------"
		
	echo "
Next, let's change the format to PKCS#8 format, which is the standard. It will 
prompt you for (1) sudo password --because of access contorls--, and a 
passphrase. The passphrase is needed for encrypting the key. This way, we add a 
second layer of security.
Make sure to memorize it, or use a password manager such as Proton Pass."
	
	sudo openssl pkcs8 -topk8 -inform PEM -outform PEM -in private/$key -out \
	private/cakey.pem -v2 aes128 || exit 1
	echo "Format changing: DONE"

	echo "
--------------------------------------------------------------------------------"

	printf "
Deleting old, unencrypted private key so that it cannot be recovered..."
	# shred will make sure that the file is unrecoverable
	shred -n 10 -u private/$key || exit 1
	echo "DONE"
	key="cakey.pem"

	echo "
--------------------------------------------------------------------------------
	"
	printf "Setting access controls to the key..."
	sudo chmod 400 private/$key || exit 1
	echo "DONE. Next, you must set the right owner to the key."

	echo "
--------------------------------------------------------------------------------"

	printf "
Before we create the certificate, let's set the Certificate Revocation List 
(CRL) Distribution Point, which is the point you'll use to distribute the CRL. 
Other's will use it to verify that a cert signed by you is not revoked.
WARNING: Once it is set, you cannot change it.
NOTE: the crl is currently named 'crl.pem', located in the current directory (./).
Enter the CRL distribution point URI, 
[ e.g., https://crl.example-root-ca.com/crl.pem ] :: "
	read crldp || exit 1
	sed -i "/\[ v3_ca \]/a\\crlDistributionPoints = URI:$crldp" openssl.cnf || \
	exit 1
	echo "DONE"

	echo "
--------------------------------------------------------------------------------"

	echo "
Now, we will create a self-signed cert for our CA, in X.509 format, that lasts 
10 years, with SHA2-512. This will use your private key, so it will prompt you 
for the passphrase."

	sudo openssl req -config openssl.cnf -key private/$key -new -x509 -days \
	3650 -sha512 -extensions v3_ca -out ./cacert.pem || exit 1
	sudo chmod 444 cacert.pem || exit 1
	
	echo "Cert creation: DONE. The cert is now accessible by anyone to read."
	
	echo "
--------------------------------------------------------------------------------
	"	
	printf "Creating a DER copy of the certificate..."
	openssl x509 -outform der -in cacert.pem -out cacert.der || exit 1
	echo "DONE"

	echo "
--------------------------------------------------------------------------------
	"
	echo "Done! Your cert is now ready to be used!"
}

# The main function
init_ca(){
	printf "Before we proceed, make sure that this script is running in the right location. Everything that we will create will be a sub-directory/sub-files of this directory. Proceed? [Y/n] :: "
	
	while : ; do
		read -r choice
		if [[ $choice == "n" || $choice == "N" ]] ; then # Wrong directory
			echo "Wrong directory, exiting..."
			exit "$DIR_INIT_ERROR"

		elif [[ $choice = "y" || $choice = "Y" ]] ; then # Correct directory
			break
			
		else # right directory
			printf "Invalid input. Try again :: "

		fi

	done
	echo "Greate! Let's keep going"

	printf "\n--------------------------------------------------------------------------------\n"

	read -rp "\nChoose a name for your local root CA :: " name

	echo "Greate name!"
	
	printf "\n--------------------------------------------------------------------------------\n"
	
	echo "Initializing.."
	initialize "$name"

	echo "
	Users must now deliver their CSR to your csr/. From there, you can sign 
	them."

	echo "Scrip ends here."
	echo "Things to do next
	1. Add profiles to openssl.cnf for extensions (make a backup).
	2. Configure the CRL extension in the profiles."
}