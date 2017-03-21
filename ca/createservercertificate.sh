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
###Server Configuration
ROOT_CA_COUNTRYNAME="US"
ROOT_CA_STATE="Pennsylvania"
ROOT_CA_LOCALITY=""
ROOT_CA_ORGANIZATION_NAME="My Company"
ROOT_CA_ORGANIZATION_UNIT_NAME="My Team"
ROOT_CA_COMMON_NAME="$HOST"
ROOT_CA_EMAIL_ADDRESS="Contact Email"
#....
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
# ./

#Create Server Private Key
cd /root/ca
read -s -p "Password: " password
openssl genrsa \
    -out intermediate/private/$HOST.key.pem 2048

chmod 400 intermediate/private/$HOST.key.pem

#Create Server Certificate Request

cd /root/ca
openssl req -config intermediate/openssl.cnf \
		-subj "/C=$ROOT_CA_COUNTRYNAME/ST=$ROOT_CA_STATE/L=$ROOT_CA_LOCALITY/O=$ROOT_CA_ORGANIZATION_NAME/OU=$ROOT_CA_ORGANIZATION_UNIT_NAME/CN=$ROOT_CA_COMMON_NAME/emailAddress=$ROOT_CA_EMAIL_ADDRESS" \
    -key intermediate/private/$HOST.key.pem \
    -new -sha256 -out intermediate/csr/$HOST.csr.pem

#Sign Server Certificate Request

cd /root/ca
openssl ca -config intermediate/openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -passin pass:'$password' \
      -in intermediate/csr/$HOST.csr.pem \
      -out intermediate/certs/$HOST.cert.pem

chmod 444 intermediate/certs/$HOST.cert.pem


#Verification
openssl x509 -noout -text \
      -in intermediate/certs/$HOST.cert.pem

#Verify Chain of Trust
openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/$HOST.cert.pem
