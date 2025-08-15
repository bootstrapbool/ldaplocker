# LDAP Locker

I didn't plan on making this public when I created it.

I apologize in advance for my terrible code and documentation...

Definitely not the most efficient password manager, I decided to use LDAP to keep things structured but also just to learn more about managing LDAP.

Most of the following instructions are just my notes to configure LDAP.

## LDAP Custom Schema

In order to get the custom.schema file to work with ldap you need to update ldap.conf.

Maybe I'll add some kind of setup script for all of this, but for now it must be done manually.

## LDAP Adding LDIF File

### Linux

#### Install Openldap

    sudo pacman -Syu openldap

#### Database Directories

    sudo mkdir /var/lib/openldap/openldap-data

    sudo install -m 0700 -o ldap -g ldap -d /var/lib/openldap/openldap-data

    sudo install -m 0760 -o root -g ldap -d /etc/openldap/slapd.d

#### Generate a Password

    slappasswd

#### Configure config.ldif

You'll need to configure openldap with a file config.ldif.

For this project this file will be located in ldif/config.ldif

Include all schema files in the config.

~~~
include: file:///etc/openldap/schema/core.ldif
include: file:///etc/openldap/schema/cosine.ldif
include: file:///etc/openldap/schema/inetorgperson.ldif
include: file:///etc/openldap/schema/nis.ldif

include: file:///etc/openldap/schema/custom.ldif
~~~

Copy ~/.ldaplocker/custom.ldif to /etc/openldap/schema/custom.ldif

    sudo cp ~/.ldaplocker/custom.ldif /etc/openldap/schema/custom.ldif

Modify the RootDN "olcRootDN: " to "cn=admin,dc=ldaplocker,dc=com"

Copy the password hash generated from running slappasswd and paste it to "olcRootPW: " in config.ldif

Ensure you add the config.ldif file as the following.

    sudo cp ~/.ldaplocker/ldif/config.ldif /etc/openldap/config.ldif

Allow logins to the ldap user account with the "chsh" command by adding "/bin/bash" as its default shell.

    sudo chsh -s /bin/bash ldap

Add the config.

    slapadd -n 0 -F /etc/openldap/slapd.d -l /etc/openldap/config.ldif

If something goes wrong when adding the config. After you fix whatever issue is in config.ldif or maybe one of the include files, you can delete the /etc/openldap/slapd.d directory and recreate it. Then run "slapadd -n 0 -F /etc/openldap/slapd.d -l /etc/openldap/config.ldif" again.

    sudo rm -R /etc/openldap/slapd.d
    sudo mkdir /etc/openldap/slapd.d
    sudo slapadd -n 0 -F /etc/openldap/slapd.d -l /etc/openldap/config.ldif

Make it so the ldap user can access everything it needs.

    chown -R ldap:ldap /etc/openldap/*

#### Make Openldap Only Listen on Localhost

Add the following to /etc/conf.d/slapd
If the file doesn't exist, add it.

~~~
SLAPD_URLS="ldap://127.0.0.1/ ldap://[::1]"
SLAPD_OPTIONS=
~~~

### MacOS

Setup instructions found [here](https://github.com/IntersectAustralia/acdata/wiki/Setting-up-OpenLDAP)

I copied the following instructions from that repo.

#### Homebrew

    brew install berkeley-db@4 openldap

#### Generate a Password

    slappasswd

#### Config File

Ensure slap.d doesn't exist in /etc/openldap/

    mv /etc/openldap/slap.d ~/temp

The config file is /usr/local/etc/openldap/slapd.conf

Ensure you do the following in this file...

1. Change "suffix" to fit your organization (ex: "dc=localhost"). Make it "dc=ldaplocker,dc=com"
2. Change "rootdn" to reflect the change you made to "suffix" (ex: cn=admin,dc=localhost). Make it "cn=admin,dc=ldaplocker,dc=com"
3. Change the rootpw to be encrypted string of the generated password above
4. Change the database type from "mdb" to "ldif"
5. Have the following in the top of slapd.conf
~~~
include   /usr/local/etc/openldap/schema/core.schema
include   /usr/local/etc/openldap/schema/cosine.schema
include   /usr/local/etc/openldap/schema/nis.schema
include   /usr/local/etc/openldap/schema/inetorgperson.schema
~~~
6. To include your custom schema first move the custom.schema file to the openldap schema directory, then add an "include" entry to slapd.conf
    mv ~/.ldaplocker/custom.schema /usr/local/etc/openldap/schema/custom.schema
    include   /usr/local/etc/openldap/schema/custom.schema
7. Copy the config file to the required location
    sudo cp /usr/local/etc/openldap/slapd.conf /etc/openldap
8. Copy the file /etc/openldap/DB_CONFIG.example and put it into /var/lib/ldap as "DB_CONFIG". Before copying make sure the directory is created.
    sudo mkdir -p /var/lib/ldap
    sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

#### Ensure the Database Directory Exists

    mkdir -p /usr/local/var/openldap-data

#### Reset the Server

    sudo rm -rf /usr/local/var/openldap-data

#### Start the LDAP Server

    sudo /usr/libexec/slapd

#### Start LDAP Server with Debugging

The <strong>-d3</strong> option enables verbose debugging.

    sudo /usr/libexec/slapd -d3

#### Security

See the following [guide](https://www.openldap.org/doc/admin24/security.html).

#### Ensure the custom schema successfully loaded.

    ldapsearch -x -H ldaps://localhost:636 -D 'cn=admin,dc=localhost' -W -s base -b 'cn=subschema' objectClasses

You should see your custom classes in the output.

## LDAP Entry Syntax

Checkout RFC 4519 for attributes.

RFC 4517 goes into the syntax of some of the values of these attributes.

## LDAP Obect Identifier (OID) Syntax

Base OID Number is... 1.3.6.1.4.1.32473

The second number will be for whether the OID is for an attribute, object class, etc...

| # | LDAP Element 
|---|-------------
| 1 | Attribute
| 2 | Object Class
| 3 | Attribute Syntaxes
| 4 | Matching Rules
| 5 | Controls

### Example

Second custom attribute defined
1.3.6.1.4.1.32473.1.2

Third defined object class
1.3.6.1.4.1.32473.2.3

## Precedence

This is my personal precedence for creating attributes, adhering to this isn't necessary.

~~~
dn
o
ou
cn/uid
description
owner
businessCategory
labeledUri
cn (if not used in dn)
device
givenName
sn
mail
mobile/telephoneNumber
registeredAddress
carLicense

objectClass
~~~

## Attribute Syntax

### 3.3.28.  Postal Address Examples

- 1234 Main St.$Anytown, CA 12345$USA
- \241,000,000 Sweepstakes$PO Box 1000000$Anytown, CA 12345$USA

### 3.3.31.  Telephone Number Examples

- +1 512 315 0280
- +1-512-315-0280
- +61 3 9896 7830

## Secrets SQLITE Database

Entries and secrets will be linked via the full distinguished name of the LDAP entry.

### Example Secrets Entries

Id, DistinguishedName, Expired, Category, Description, Secret
1, 'uid=username1,o=xbox', 0, 'password', '', fjioawpu8rh938290==
2, 'uid=username1,o=xbox', 0, 'security question', 'Name of first dog?', 3r2893noury==
3, 'uid=username1,o=xbox', 0, 'security question', 'Name of highschool?', oahf9y8h==
