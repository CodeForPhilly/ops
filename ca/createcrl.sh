#!/bin/sh
#This should be setup with a cron job to run every 29 days.
#Create CRL

# Init
FILE="/tmp/out.$$"
GREP="/bin/grep"
#....
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
# ./

cd /root/ca
read -s -p "Password: " password
openssl ca -config intermediate/openssl.cnf \
      	-passin pass:'$password' \
      	-gencrl -out intermediate/crl/intermediate.crl.pem

openssl crl -inform PEM \
		-in intermediate/crl/intermediate.crl.pem \
		-outform DER \
		-out intermediate/crl/intermediate.crl

rm intermediate.crl.pem

#copy file to http root

rsync -avz /root/ca/intermediate/crl/intermediate.crl /var/www/html/