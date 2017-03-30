--
-- Dumping data for table `org_role`
--
INSERT INTO sphereds.org_role (org_account_id, name, active, access_level, type) VALUES
  (1, 'Global Admin',   1, 1, 'GLOBAL_ADMIN'),
  (1, 'MSP Admin',      1, 1, 'MSP_ADMIN'),
  (1, 'Account Admin',  1, 0, 'ACCOUNT_ADMIN'),
  (1, 'User',           1, 0, 'USER');
--
-- Dumping data for table `org_module`
--
INSERT INTO sphereds.org_module (name, active, site_module) VALUES

  /* System management */
  ('ACCOUNT',        1, 0),
  ('USER',           1, 0),
  ('ROLE',           1, 0),
  ('THEME',          1, 0),
  ('RESOURCE',       1, 0),
  ('SITE',           1, 0),

  /* Compute */
  ('SERVER',         1, 1),
  ('TEMPLATE',       1, 1),
  ('ISO',            1, 1),
  ('VOLUME',         1, 1),
  ('SNAPSHOT',       1, 1),
  ('VPC',            1, 1),
  ('SUBNET',         1, 1),
  ('PORT',           1, 1),
  ('ROUTER',         1, 1),
  ('FLOATING_IP',    1, 1),
  ('LOADBALANCER',   1, 1),
  ('SECURITY_GROUP', 1, 1),
  ('IP',             1, 1),
  ('OFFERING',       1, 1),
  ('KEY_PAIR',       1, 1),
  /* General */
  ('EVENT',          1, 0),
  ('PRICING',        1, 0),
  ('USAGE',          1, 0),
  ('TICKET',         1, 0);

--
-- Dumping data for table `org_role_module_permission`
--

INSERT INTO sphereds.org_role_module_permission (org_role_id, org_module_id, permission) VALUES

  /* Role: Global admin */
  /* System management */
  ((SELECT id FROM org_role where type="GLOBAL_ADMIN"), (SELECT id FROM org_module WHERE name="ACCOUNT"),         15),
  ((SELECT id FROM org_role where type="GLOBAL_ADMIN"), (SELECT id FROM org_module WHERE name="USER"),            15),
  ((SELECT id FROM org_role where type="GLOBAL_ADMIN"), (SELECT id FROM org_module WHERE name="ROLE"),            15),
  ((SELECT id FROM org_role where type="GLOBAL_ADMIN"), (SELECT id FROM org_module WHERE name="THEME"),           15),
  /* General */
  ((SELECT id FROM org_role where type="GLOBAL_ADMIN"), (SELECT id FROM org_module WHERE name="EVENT"),           15),

  /* Role: MSP admin */
  /* System management */
  ((SELECT id FROM org_role where type="MSP_ADMIN"), (SELECT id FROM org_module WHERE name="ACCOUNT"),            15),
  ((SELECT id FROM org_role where type="MSP_ADMIN"), (SELECT id FROM org_module WHERE name="USER"),               15),
  ((SELECT id FROM org_role where type="MSP_ADMIN"), (SELECT id FROM org_module WHERE name="RESOURCE"),           15),
  ((SELECT id FROM org_role where type="MSP_ADMIN"), (SELECT id FROM org_module WHERE name="SITE"),               15),
  /* Compute */
  ((SELECT id FROM org_role where type="MSP_ADMIN"), (SELECT id FROM org_module WHERE name="TEMPLATE"),           15),
  ((SELECT id FROM org_role where type="MSP_ADMIN"), (SELECT id FROM org_module WHERE name="OFFERING"),           15),
  /* General */
  ((SELECT id FROM org_role where type="MSP_ADMIN"), (SELECT id FROM org_module WHERE name="EVENT"),              15),
  ((SELECT id FROM org_role where type="MSP_ADMIN"), (SELECT id FROM org_module WHERE name="PRICING"),            15),
  
  /* Role: Account admin */
  /* System management */
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="ACCOUNT"),        15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="USER"),           15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="RESOURCE"),       15),
  /* Compute */
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="SERVER"),         15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="TEMPLATE"),       15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="ISO"),            15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="VOLUME"),         15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="SNAPSHOT"),       15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="VPC"),            15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="SUBNET"),         15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="PORT"),           15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="ROUTER"),         15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="FLOATING_IP"),    15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="LOADBALANCER"),   15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="SECURITY_GROUP"), 15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="IP"),             15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="OFFERING"),       15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="KEY_PAIR"),       15),
  /* General */
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="EVENT"),          15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="TICKET"),         15),
  ((SELECT id FROM org_role where type="ACCOUNT_ADMIN"), (SELECT id FROM org_module WHERE name="USAGE"),          15),

  /* Role: User */
  /* System management */
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="USER"),                    15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="RESOURCE"),                15),
  /* Compute */
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="SERVER"),                  15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="TEMPLATE"),                15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="ISO"),                     15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="VOLUME"),                  15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="SNAPSHOT"),                15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="VPC"),                     15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="SUBNET"),                  15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="PORT"),                    15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="ROUTER"),                  15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="FLOATING_IP"),             15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="LOADBALANCER"),            15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="SECURITY_GROUP"),          15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="IP"),                      15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="OFFERING"),                15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="KEY_PAIR"),                15),
  /* General */
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="EVENT"),                   15),
  ((SELECT id FROM org_role where type="USER"), (SELECT id FROM org_module WHERE name="TICKET"),                  15);

