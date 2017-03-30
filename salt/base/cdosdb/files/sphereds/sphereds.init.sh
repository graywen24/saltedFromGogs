#!/bin/bash 
. ./sphereds.config

if [ "$dbpass" == "" ]
then 
  myrootuser="-u root"
else
  myrootuser="-u root -p$dbpass"
fi

#############################################
############# DB SCHEMA #####################
#############################################
echo "Create sphereds schema"  
mysql $myrootuser < ./sphereds.create.schema.sql

#############################################
############# CDYNAMICS USER ################
#############################################
echo "Creating cdynamics user" 
mysql $myrootuser < ./create.cdynamics.user.sql 


#############################################
############# SYS CONFIG ####################
#############################################
echo "Loading sys configuration" 
mysql $myrootuser sphereds << EOF 
  LOAD DATA LOCAL INFILE '$sysconfiguration'
    INTO TABLE sphereds.sys_configuration
    FIELDS TERMINATED BY ';';
EOF

#############################################
############# POPULATE ROLES ################
#############################################
echo "Populating roles"
mysql $myrootuser sphereds < ./insert.org.roles.sql

#############################################
############# POPULATE DB ###################
#############################################
echo "Populating System Default Values"
mysql $myrootuser sphereds < ./system.default




