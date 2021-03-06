INSERT INTO `sphereds`.`site_2fa` (provider_type,name,access_url,api_key)
SELECT 'DEFA','1NET','http://{{ pillar.cdos.defa.host }}:{{ pillar.cdos.defa.port }}/v1','{{ pillar.cdos.defa.apikey }}'
FROM  `sphereds`.`org_site` WHERE NOT EXISTS (SELECT * FROM `sphereds`.`site_2fa` WHERE provider_type = 'DEFA')
LIMIT 1;
COMMIT WORK;
