#!/bin/bash

HOST=$1

if [ -z $HOST ]; then
  echo "Need to give a proper host fqdn!"
  exit 0
fi

icinga2 pki new-cert --cn $HOST \
--key /tmp/${HOST}.key \
--cert /tmp/${HOST}.crt \
--csr /tmp/${HOST}.csr

icinga2 pki sign-csr --cert /tmp/${HOST}.crt \
--csr /tmp/${HOST}.csr

echo "BEGIN_OUTPUT"
echo "cat << EOF > /etc/icinga2/pki/${HOST}.key"
cat /tmp/$HOST.key
echo 'EOF'
echo
echo "cat << EOF > /etc/icinga2/pki/${HOST}.crt"
cat /tmp/$HOST.crt
echo 'EOF'
echo
echo "cat << EOF > /etc/icinga2/pki/trusted-master.crt"
cat /etc/icinga2/pki/icinga-a1.cde.1nc.crt
echo 'EOF'
echo
echo "cat << EOF > /etc/icinga2/pki/ca.crt"
cat /etc/icinga2/pki/ca.crt
echo 'EOF'
echo 'chown nagios.nagios /etc/icinga2/pki/*'

#rm /tmp/${HOST}.*
