GRANT USAGE ON *.* TO 'cdynamics'@'{{ pillar.cdos.mysql.origin }}';
DROP USER 'cdynamics'@'{{ pillar.cdos.mysql.origin }}';
FLUSH PRIVILEGES;
COMMIT WORK;
CREATE USER 'cdynamics'@'{{ pillar.cdos.mysql.origin }}' IDENTIFIED BY 'F5I4Lh1>Jp';
GRANT ALL ON sphereds.* TO 'cdynamics'@'{{ pillar.cdos.mysql.origin }}';
FLUSH PRIVILEGES;
COMMIT WORK;
