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


###OSCP Configuration
ROOT_CA_COUNTRYNAME="US"
ROOT_CA_STATE="STATE"
ROOT_CA_LOCALITY=""
ROOT_CA_ORGANIZATION_NAME="ORG"
ROOT_CA_ORGANIZATION_UNIT_NAME="ORG Certificate Authority"
ROOT_CA_COMMON_NAME="something.something.com"
ROOT_CA_EMAIL_ADDRESS="responsible@org.com"
#Create the OCSP Pair
read -s -p "Password: " password
cd /root/ca
openssl genrsa -aes256 \
      -passout pass:'$password' \
      -out intermediate/private/a-96-119-28-175.sys.comcast.net.key.pem 4096


#Create CSR to Sign
cd /root/ca
openssl req -config intermediate/openssl.cnf -new -sha256 \
      -key intermediate/private/a-96-119-28-175.sys.comcast.net.key.pem \
      -passin pass:'$password' \
      -out intermediate/csr/a-96-119-28-175.sys.comcast.net.csr.pem \
      -subj "/C=$ROOT_CA_COUNTRYNAME/ST=$ROOT_CA_STATE/L=$ROOT_CA_LOCALITY/O=$ROOT_CA_ORGANIZATION_NAME/OU=$ROOT_CA_ORGANIZATION_UNIT_NAME/CN=$ROOT_CA_COMMON_NAME/emailAddress=$ROOT_CA_EMAIL_ADDRESS"


#Sign the CSR with the intermediate CA
openssl ca -config intermediate/openssl.cnf \
      -passin pass:'$password' \
      -extensions ocsp -days 375 -notext -md sha256 \
      -in intermediate/csr/a-96-119-28-175.sys.comcast.net.csr.pem \
      -out intermediate/certs/a-96-119-28-175.sys.comcast.net.cert.pem

#Verify the certificate
echo "---------Please verify:"
openssl x509 -noout -text \
      -in intermediate/certs/a-96-119-28-175.sys.comcast.net.cert.pem

