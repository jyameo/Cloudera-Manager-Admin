#!/bin/bash

cd /root
chmod 755 /etc
chmod 755 /etc/hadoop

# install the kerberos components
yum install -y krb5-server
yum install  -y openldap-clients
yum -y install krb5-workstation


# set the Realm
# this would normally be YOURCOMPANY.COM
# in this case the hostname is cm.cloudera
# so the equivalent domain name is CLOUDERA
sed -i.orig 's/EXAMPLE.COM/c.cloudera-manager-cdc.internal/g' /etc/krb5.conf
# set the hostname for the kerberos server
sed -i.m1 's/kerberos.example.com/cm.c.cloudera-manager-cdc.internal/g' /etc/krb5.conf
# change domain name to cloudera
sed -i.m2 's/example.com/c.cloudera-manager-cdc.internal/g' /etc/krb5.conf

# now create the kerberos database
# type in cloudera at the password prompt
echo suggested password is cloudera 

kdb5_util create -s

# update the kdc.conf file
sed -i.orig 's/EXAMPLE.COM/c.cloudera-manager-cdc.internal/g' /var/kerberos/krb5kdc/kdc.conf
# this will add a line to the file with ticket life
sed -i.m1 '/dict_file/a max_life = 1d' /var/kerberos/krb5kdc/kdc.conf
# add a max renewable life
sed -i.m2 '/dict_file/a max_renewable_life = 7d' /var/kerberos/krb5kdc/kdc.conf
# indent the two new lines in the file
sed -i.m3 's/^max_/  max_/' /var/kerberos/krb5kdc/kdc.conf

# the acl file needs to be updated so the */admin
# is enabled with admin privileges
sed -i 's/EXAMPLE.COM/c.cloudera-manager-cdc.internal/' /var/kerberos/krb5kdc/kadm5.acl

# update the kdc.conf file to allow renewable
sed -i.m3 '/supported_enctypes/a default_principal_flags = +renewable, +forwardable' /var/kerberos/krb5kdc/kdc.conf
# fix the indenting
sed -i.m4 's/^default_principal_flags/  default_principal_flags/' /var/kerberos/krb5kdc/kdc.conf



service krb5kdc start
service kadmin start

# add the admin user that CM will use to provision
# kerberos in the cluster
kadmin.local