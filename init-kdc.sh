#!/bin/bash

# Create the secrets directory if it doesn't exist (just in case)
mkdir -p /var/kerberos/krb5kdc/secrets

add_princ() {
    local princ="$1"
    if ! kadmin.local -q "getprinc $princ" | grep -q "Principal: $princ"; then
        echo "Creating principal: $princ"
        kadmin.local -q "addprinc -randkey $princ"
    else
        echo "Principal $princ already exists."
    fi
}

echo "--- Starting KDC Initialization ---"

add_princ "nn/namenode@EXAMPLE.COM"
add_princ "dn/datanode1@EXAMPLE.COM"
add_princ "dn/datanode2@EXAMPLE.COM"
add_princ "HTTP/namenode@EXAMPLE.COM"

echo "--- Exporting Keytabs ---"
kadmin.local -q "ktadd -k /var/kerberos/krb5kdc/secrets/nn.keytab -norandkey nn/namenode@EXAMPLE.COM HTTP/namenode@EXAMPLE.COM"
kadmin.local -q "ktadd -k /var/kerberos/krb5kdc/secrets/dn1.keytab -norandkey dn/datanode1@EXAMPLE.COM"
kadmin.local -q "ktadd -k /var/kerberos/krb5kdc/secrets/dn2.keytab -norandkey dn/datanode2@EXAMPLE.COM"


chmod 644 /var/kerberos/krb5kdc/secrets/*.keytab

echo "--- Starting Supervisord (KDC Service) ---"
exec /usr/bin/supervisord -n -c /etc/supervisord.conf