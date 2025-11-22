#!/bin/bash
# Importing files
source "$SCRIPT_DIR/utils/gen_root_ca_cert.sh"

initialize(){
	# Firstly, we need to create five directories to confront to X.509
	echo -e "$INFO	Creating directories..."
	if mkdir -p pkix/"$1"/{certs,crl,csr,newcerts,private} ; then
		echo -e "$INFO	Creating directories :: DONE."
	else
		echo -e "$ERROR	Could not create the directories due to an unknown error, exiting..."
		exit "$DIR_INIT_ERROR"
	fi

	if cd "pkix/$1" ; then
		echo -e "$INFO	Moving to 'pkix/'... DONE"
	else
		echo -e "$ERROR	Could not move to 'pkix/', exiting..."
		exit "$CD_ERROR"
	fi

	echo -e "$INFO	Setting access controls to 'priate/'..."
	if sudo chmod 700 private/ ; then
		echo -e "$INFO	Setting access contros :: DONE"
	else
		echo -e "$ERROR	Could not set access controls, exiting..."
		exit "$PERMS_ERROR"
	fi

	printf "\n--------------------------------------------------------------------------------\n\n"

	echo -e "$INFO	Copying OpenSSL's configuration file..."

	# Copying OpenSSL's configuration file, preserving some attributes
	if sudo cp --preserve=mode,ownership,timestamps,context,xattr \
		/etc/ssl/openssl.cnf ./openssl.cnf ; then
		echo -e "$INFO	Copying OpenSSL's configuration file :: DONE."

	else
		echo -e "$ERROR	Could not copy openssl.cnf configuration file, exiting..."
		exit "$CP_ERROR"
	fi

	echo -e "$INFO	We've copied openssl.cnf for no reason other than preserving the configuration file's attributes. We'll overwrite it now. We need your privileges. But before that, let's learn more about you\!. Postscriptum: this knowledge will be used in nothing other than setting your OpenSSL configuration :)"
	
	local country; local state; local locality; local org
	read -rp "What's your country's two character code? :: " country

	read -rp "What's your state or province's name? :: " state

	read -rp "What's your locality (e.g., city) name? :: " locality
	
	read -rp "What's your organization's name? :: " org

	sudo echo "[ ca ] # How the 'ca' command will act when utilized to sign certs
	default_ca		= ca_default # The name of the default CA section

[ ca_default ] # defining the default CA section
	dir			= $(pwd)		# Default root directory
	certs			= \$dir/certs		# Default certificates directory
	new_certs_dir		= \$certs		# Default new certificates directory
	database		= \$dir/index.txt	# Database of certificates
	certificate		= \$dir/cacert.pem	# The default CA's certificate
	private_key		= \$dir/private/cakey.pem	# the default CA's private key
	serial			= \$dir/serial		# A database of serials.
	crldir			= \$dir/crl			# Default CRL directory 
	crlnumber		= \$dir/crlnumber	# CRL serial
	crl			= \$crldir/crl.pem	# CRL file.
	RANDFILE		= \$dir/private/.rand	# File of random data, need to set up the script to fill it from the /dev/urandom
	name_opt		= ca_default 		# How the name is displayed to you for confirmation
	cert_opt		= ca_default 		# How the certificate is displayed to you for confirmation
	default_days		= 90
	default_crl_days	= 30
	default_md		= sha256
	preserve		= no			# Do not allow people to determine the order of their DN.
	policy			= policy_match 		# Strict policy

[ policy_match ]
	countryName		= match
	stateOrProvinceName	= match
	localityName		= match			# Locality name (e.g., city)
	organizationName	= match
	organizationalUnitName 	= optional
	commonName		= supplied
	emailAddress		= optional

[ policy_anything ]
	countryName		= optional
	stateOrProvinceName	= optional
	localityName		= optional
	organizationName	= optional
	organizationalUnitName	= optional
	commonName		= supplied
	emailAddress		= optional

[ req ]	# a section for the req command
	default_bits		= 3072
	default_keyfile		= \dir/privkey.pem
	distinguished_name	= req_distinguished_name # referencing a section
	attributes		= req_attributes  	# referencing a section
	x509_extensions		= v3_ca  		# referencing a section
	req_extensions		= v3_req 		# referencing a section
	string_mask 		= utf8only

[ req_distinguished_name ]
	countryName		= Country Name (2 letter code)
	countryName_default	= $country
	countryName_min		= 2
	countryName_max		= 2

	stateOrProvinceName	= State or Province Name (full name)
	stateOrProvinceName_default = $state

	localityName		= Locality Name (eg, city)
	localityName_default	= $locality

	0.organizationName	= Organization Name (eg, company)
	0.organizationName_default = $org

	organizationalUnitName	= Organizational Unit Name (eg, section)

	commonName		= Common Name (eg, YOUR name)
	commonName_max		= 64

	emailAddress    	= Email Address
	emailAddress_max	= 64

[ req_attributes ]
	challengePassword	= A challenge password
	challengePassword_min	= 8
	challengePassword_max	= 20
	
[ v3_req ]

	basicConstraints	= CA:FALSE
	keyUsage		= digitalSignature, keyAgreement
	#subjectAltName		= email:copy

[ ecdsa_polsect ]
	policyIdentifier	= 1.3.6.1.5.5.7.3.1	# for serverAuth
	userNotice.1 		= @notice

[ ecdsa_polsect ]
	policyIdentifier	= 1.3.6.1.5.5.7.3.1	# for serverAuth too... Couldn't find any better
	userNotice.1		= @notice

[notice]
	explicitText		= 'This CA policy covers the following requirements: Common Name is required, other fields are optional. All certificates must comply with the CA\'s operational standards and policies.'
	organization		= '$org'
	noticeNumbers		= 1	# I only have one security policy anyway.

[ ca_polsect ]
	policyIdentifier	= 1.3.6.1.5.5.7.3.27	# for serverAuth
	userNotice.1 		= @notice

[ v3_ca ]
	subjectKeyIdentifier	= hash
	authorityKeyIdentifier	= keyid:always,issuer:always
	basicConstraints	= critical,CA:true
	subjectAltName		= email:copy
	issuerAltName		= email:copy
	keyUsage 		= cRLSign, keyCertSign, digitalSignature
	subjectAltName		= email:copy
	certificatePolicies 	= ia5org, @ca_polsect

[ v3_server_kex ] # profile
	basicConstraints	= CA:FALSE

	authorityKeyIdentifier	= keyid,issuer # the hash of the key
	subjectKeyIdentifier	= hash			
	keyUsage		= keyAgreement, digitalSignature # used for key # establishment

	subjectAltName		= email:copy # moves the email from the DN to the SAN
	issuerAltName		= issuer:copy
	extendedKeyUsage	= serverAuth # An other usage of the key is to authenticate the server to the client. I have commented it because diffie-helmann is not used to authenticate but to establish keys.
	
[ v3_server_sig ] # profile
	basicConstraints	= CA:FALSE
	authorityKeyIdentifier	= keyid,issuer
	subjectKeyIdentifier	= hash
	keyUsage		= digitalSignature, keyEncipherment
	subjectAltName		= email:copy
	issuerAltName		= issuer:copy
	extendedKeyUsage	= serverAuth" | sudo tee openssl.cnf

	printf "\n--------------------------------------------------------------------------------\n\n"

	echo -e "$INFO	Creating DB index.txt..."
	if touch index.txt ; then
		echo -e "$INFO	DB creating ::  DONE."
	else
		echo -e "$ERROR	Could not create index.txt, is it a permission error? Please create index.txt on your own."
	fi

	printf "\n--------------------------------------------------------------------------------\n\n"

	echo -e "$INFO	Creating serial and CRL serial..."
	if echo 00 > serial && echo 00 > crlnumber ; then						
		echo -e "$INFO	Serial and CRL serial creation ::  DONE."
	else
		echo -e "$ERROR	Could NOT create the certificate serial file and CRL serial file. Please do so, and put 00 in each one of them."
	fi

	printf "\n--------------------------------------------------------------------------------\n\n"

	echo -e "$INFO	Environment creation ::  DONE."

	printf "\n--------------------------------------------------------------------------------\n\n"
	
	echo -e "$INFO	Proceeding to root CA generation..."
	gen_root_cert # Calling function to generate root CA cert

	printf "\n--------------------------------------------------------------------------------\n\n"
	
	echo -e "$INFO	Creating certificate revokation list..."
	if sudo openssl ca -config openssl.cnf -gencrl -out crl.pem ; then
		echo -e "$INFO	CRL creation :: DONE"
	else
		echo -e "$ERROR	Could not create the CRL, exiting..."
		exit "$SSL_ERROR"
	fi

	printf "\n--------------------------------------------------------------------------------\n\n"

	echo -e "$INFO	Initialization has finished."
}