#!/bin/sh
#Author: Kristerpher Henderson
#Date Created: 01/12/2016

# Init
FILE="/tmp/out.$$"
GREP="/bin/grep"
#....
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
# ...

###CA Configuration
ROOT_CA_COUNTRYNAME="US"
ROOT_CA_STATE="Pennsylvania"
ROOT_CA_LOCALITY=""
ROOT_CA_ORGANIZATION_NAME="My Org"
ROOT_CA_ORGANIZATION_UNIT_NAME=""
ROOT_CA_COMMON_NAME="Root CA"
ROOT_CA_EMAIL_ADDRESS=""


##Create the Root Tree

mkdir /root/ca
cd /root/ca
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial


##Create the Root Key with prompt
read -s -p "Password: " password
cd /root/ca
openssl genrsa -aes256 \
		-passout pass:'$password' \
		-out private/ca.key.pem 4096
chmod 400 private/ca.key.pem


##Create the Root Certificate
cd /root/ca
openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -passin pass:'$password' \
      -out certs/ca.cert.pem \
      -subj "/C=$ROOT_CA_COUNTRYNAME/ST=$ROOT_CA_STATE/L=$ROOT_CA_LOCALITY/O=$ROOT_CA_ORGANIZATION_NAME/OU=$ROOT_CA_ORGANIZATION_UNIT_NAME/CN=$ROOT_CA_COMMON_NAME/emailAddress=$ROOT_CA_EMAIL_ADDRESS"


#Set Pemissions
chmod 444 certs/ca.cert.pem

#Verify
openssl x509 -noout -text -in certs/ca.cert.pem
