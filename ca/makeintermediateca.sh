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

###Make Intermediate CA
ROOT_CA_COUNTRYNAME="US"
ROOT_CA_STATE="STATE"
ROOT_CA_LOCALITY=""
ROOT_CA_ORGANIZATION_NAME="ORG"
ROOT_CA_ORGANIZATION_UNIT_NAME="ORG Certificate Authority"
ROOT_CA_COMMON_NAME="ORG Root CA"
ROOT_CA_EMAIL_ADDRESS="responsible@org.com"

#Prepare the Directory
mkdir /root/ca/intermediate
cd /root/ca/intermediate
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > /root/ca/intermediate/crlnumber


#Create Intermediate key
read -s -p "Password: " password
cd /root/ca
openssl genrsa -aes256 \
      -passout pass:'$password' \
      -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key

#Create the intermediate certificate

cd /root/ca
openssl req -config intermediate/openssl.cnf -new -sha256 \
      -passin pass:'$password' \
      -key intermediate/private/intermediate.key.pem \
      -out intermediate/csr/intermediate.csr.pem \
      -subj "/C=$ROOT_CA_COUNTRYNAME/ST=$ROOT_CA_STATE/L=$ROOT_CA_LOCALITY/O=$ROOT_CA_ORGANIZATION_NAME/OU=$ROOT_CA_ORGANIZATION_UNIT_NAME/CN=$ROOT_CA_COMMON_NAME/emailAddress=$ROOT_CA_EMAIL_ADDRESS"

cd /root/ca
openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
      -passin pass:'$password' \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem

chmod 444 intermediate/certs/intermediate.cert.pem

#Output
openssl x509 -noout -text \
      -in intermediate/certs/intermediate.cert.pem

#Verify
openssl verify -CAfile certs/ca.cert.pem \
      intermediate/certs/intermediate.cert.pem

#After verification you can cretae chain of trust
read -p "Verification look good? If so, would you like to create a chain of trust? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
cat intermediate/certs/intermediate.cert.pem \
      certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem
fi