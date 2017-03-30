#!/bin/bash 
. ./sphereds.config

if [ "$dbpass" == "" ]
then 
  myrootuser="-u root"
else
  myrootuser="-u root -p$dbpass"
fi

#############################################
############# CLOUDSTACK BASIC ##############
#############################################
if [ "$sync_cloudstack" == "y" ]
then
  echo "Syncing cloudstack database" 
  ./sync-cloudstack-db.sh
fi


#############################################
############# CLOUDSTACK BASIC ##############
#############################################
if [ "$install_cloudstack_basic" == "y" ] 
then
echo "Installing cloudstack basic site" 
mysql $myrootuser sphereds << EOF 
   # Cloudstack Site
  insert into sphereds.org_site (
    org_site_type_id, 
    name,
    provider_id,
    provider_type,
    access_url,
    active,
    responseformat, 
    apikey ,
    secretkey, 
    resourcepath,  
    requireupdate,  
    signin_url ,
    cookie_domain ,
    site_vmconsole_url ,
    site_cru_capacity  ,
    site_zone_id ,
    site_domain_id ,
    site_region_id  ,
    site_version 
    )
  select 
    1,
    dc.name,
    1,
    upper(dc.networktype),
    '$cs_basic_access_url',
    1,
    'json',
    u.api_key,
    u.secret_key ,
    '/client/api',
    1,
    '$cs_basic_signin_url',
    '$cs_basic_cookie_domain',
    '$cs_basic_site_vmconsole_url',
    1000,
    dc.uuid,
    dom.uuid,
    null,
    '$cs_basic_site_version'
  from
    cloud.data_center dc,
    cloud.user u,
    cloud.domain dom
  where dc.name="$cs_basic_zone_name" 
      and dom.name="$cs_basic_domain_name"
      and u.username="$cs_basic_user_name"
  LIMIT 1;
  COMMIT WORK;

  INSERT INTO org_site_ip (
    org_site_id,
    siteresourceid,
    ipaddress,
    status
  )

  SELECT 
    site.id,
    uuid(),
    '142.0.144.163',
    1
  FROM 
    org_site site
  where site.name="$cs_basic_zone_name";
  COMMIT WORK;  

EOF

#############################################
############# METER CRU RESOURCE ############
#############################################
echo "Loading meter cru resource" 
siteid=$(mysql $myrootuser sphereds -se "SELECT id FROM sphereds.org_site where name='$cs_basic_zone_name'")
sed "s/DUMMY/$siteid/g" "$metercruresourceshell" > $metercruresource
mysql $myrootuser sphereds << EOF 
  SET SQL_MODE = '';
  LOAD DATA LOCAL INFILE '$metercruresource'
    INTO TABLE sphereds.meter_cru_resource    
    FIELDS TERMINATED BY ';';
    COMMIT WORK;
EOF

for ip in "${cs_basic_ips[@]}"
do
mysql $myrootuser sphereds << EOF
  INSERT INTO org_site_ip (
    org_site_id,
    siteresourceid,
    ipaddress,
    status
  )
  SELECT 
    site.id,
    uuid(),
    '$ip',
    1
  FROM 
    org_site site
  where site.name="$cs_basic_zone_name";
  COMMIT WORK;
EOF
done

fi

#############################################
############# CLOUDSTACK ADVANCE ############
#############################################
if [ "$install_cloudstack_advance" == "y" ] 
then
echo "Installating cloudstack advance site" 
mysql $myrootuser sphereds << EOF 
   # Cloudstack Site
  insert into sphereds.org_site (
    org_site_type_id, 
    name,
    provider_id,
    provider_type,
    access_url,
    active,
    responseformat, 
    apikey ,
    secretkey, 
    resourcepath,  
    requireupdate,  
    signin_url ,
    cookie_domain ,
    site_vmconsole_url ,
    site_cru_capacity  ,
    site_zone_id ,
    site_domain_id ,
    site_region_id  ,
    site_version 
    )
  select 
    1,
    dc.name,
    1,
    upper(dc.networktype),
    '$cs_advance_access_url',
    1,
    'json',
    u.api_key,
    u.secret_key ,
    '/client/api',
    1,
    '$cs_advance_signin_url',
    '$cs_advance_cookie_domain',
    '$cs_advance_site_vmconsole_url',
    1000,
    dc.uuid,
    dom.uuid,
    null,
    '$cs_advance_site_version'
  from
    cloud.data_center dc,
    cloud.user u,
    cloud.domain dom
  where dc.name="$cs_advance_zone_name" 
      and dom.name="$cs_advance_domain_name"
      and u.username="$cs_advance_user_name"
  LIMIT 1;
  COMMIT WORK;

EOF

#############################################
############# METER CRU RESOURCE ############
#############################################
echo "Loading meter cru resource" 
siteid=$(mysql $myrootuser sphereds -se "SELECT id FROM sphereds.org_site where name='$cs_advance_zone_name'")
sed "s/DUMMY/$siteid/g" "$metercruresourceshell" > $metercruresource
mysql $myrootuser sphereds << EOF 
  SET SQL_MODE = '';
  LOAD DATA LOCAL INFILE '$metercruresource'
    INTO TABLE sphereds.meter_cru_resource
    FIELDS TERMINATED BY ';';
    COMMIT WORK;
EOF

for ip in "${cs_advance_ips[@]}"
do
mysql $myrootuser sphereds << EOF
  INSERT INTO org_site_ip (
    org_site_id,
    siteresourceid,
    ipaddress,
    status
  )
  SELECT 
    site.id,
    uuid(),
    '$ip',
    1
  FROM 
    org_site site
  where site.name="$cs_advance_zone_name";
  COMMIT WORK;
EOF
done

fi

#############################################
############# OPENSTACK #####################
#############################################
if [ "$sync_openstack" == "y" ] 
then
  ./sync-openstack-db.sh
fi

if [ "$install_openstack" == "y" ] 
then
echo "Installing openstack site" 
mysql $myrootuser sphereds << EOF 
  # Openstack
  insert into sphereds.org_site (
    org_site_type_id, 
    name,
    provider_id,
    provider_type,
    access_url,
    active,
    responseformat, 
    apikey ,
    secretkey, 
    resourcepath,  
    requireupdate,  
    signin_url ,
    cookie_domain ,
    site_vmconsole_url ,
    site_cru_capacity  ,
    site_zone_id ,
    site_domain_id ,
    site_region_id  ,
    site_version 
    )
  select 
    1,
    '$os_site_name',
    4,
    '$os_network_type',
    '$os_access_url',
    1,
    'json',
    '$os_admin_user',
    '$os_admin_password',
    '',
    1,
    '$os_access_url',
    '$cookie_domain',
    '$os_access_url',
    1000,
    '',
    p.id,
    null,
    '$os_version'
    from 
      keystone.project p
    where 
      p.name='admin';
  COMMIT WORK;
  
EOF

#############################################
############# METER CRU RESOURCE ############
#############################################
echo "Loading meter cru resource" 
siteid=$(mysql $myrootuser sphereds -se "SELECT id FROM sphereds.org_site where name='$os_site_name'")
sed "s/DUMMY/$siteid/g" "$metercruresourceshell" > $metercruresource
mysql $myrootuser sphereds << EOF 
  SET SQL_MODE = '';
  LOAD DATA LOCAL INFILE '$metercruresource'
    INTO TABLE sphereds.meter_cru_resource
    FIELDS TERMINATED BY ';';
    COMMIT WORK;
EOF

for ip in "${os_ips[@]}"
do
mysql $myrootuser sphereds << EOF
  INSERT INTO org_site_ip (
    org_site_id,
    siteresourceid,
    ipaddress,
    status
  )
  SELECT 
    site.id,
    uuid(),
    '$ip',
    1
  FROM 
    org_site site
  where site.name="$os_site_name";
  COMMIT WORK;
EOF
done

fi  