Project-Pokemon
===============

Secure TLS with Certificate Authority of data transit between external entity and internal entity.

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
