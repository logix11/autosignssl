# autosignssl
AutoSignSSL is a Bash-based software that establishes a local, root Certificate Authority (CA), and helps you manage your local root CA, including generating keys and X.509 certificates, signing, revoking and verifying certificates, all used with OpenSSL CLI program.

This program supercedes the pkix_setup that I had created earler.

## Dependencies
This is a Bash (5.2.32(1)-release) code using OpenSSL (OpenSSL 3.2.2 4 Jun 2024) and will need root privileges (to se up access controls and access the private key).\
Other than these two, you only need basic knowledge of SSL/TLS and of cryptography. The program will establish the CA and will prompt you to answer some questions. Moreover, you'll need to know what keys you want to generate. Lastly, you'll need to know how to verify a Certificate Signing Request before signing on it.\

## Features

    1. Establish the CA by setting up its environment and configuration;
    2. Generate keys;
    3. Generate certificate signing requests (CSRs);
    4. Sign on CSRs to generate certificates;
    4. Verify certificates;
    5. Visualize certificates;
    
