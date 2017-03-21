Auto Build CA
===============

Secure TLS with Certificate Authority build of Root CA and Intermediate CA

Components
-------------

The following components are considered.

> **Servers/Hosts**

> - 1 Root CA (Only to be used to generate certificate to sign Intermediate)
> - 1 Intermediate CA


> **Scripts**

> - Root CA Creation [makerootca.sh]
> - Intermediate CA Creation [makeintermediateca.sh]
> - OCSP CA Creation [makerootocsp.sh]
> - Make Server Certificate [createservercertificate.sh]

Getting Started
---------------

You will be buiding two Certificate Authorities, a Root CA which will only be used to sign the Intermediate CA. The Intermdiate CA will be used to assign certificates.

You will also need to choose a revocation strategy, CRL or OSCP.

> 1. Copy the directory to a location on your server.
> 2. configure the openssl.cnf
> 3. Edit the makecaroot.sh and makintermediateca.sh configuration variables for your CA.
