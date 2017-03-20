#!/bin/sh
#Create Server Certificate

#Check host argument
if [ $# -eq 0 ]
  then
    echo "server FQDN not supplied (servname.atsomedomain.com)"
    exit 1
fi

# Init
HOST=$1
FILE="/tmp/out.$$"
GREP="/bin/grep"

#....
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
# ./


#Revoke Server Certificate
cd /root/ca
read -s -p "Password: " password
openssl ca -config intermediate/openssl.cnf \
      -passin pass:'$password' \
      -revoke intermediate/certs/$HOST.cert.pem