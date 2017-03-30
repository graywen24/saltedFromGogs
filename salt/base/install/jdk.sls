
{% set versiondir = 'jdk1.8.0_31' %}

extract_java:
  archive.extracted:
  - name: /usr/lib/jvm/
  - source: http://repo.cde.1nc/files/jdk-8u31-linux-x64.tar.gz
  - source_hash: md5=173e24bc2d5d5ca3469b8e34864a80da
  - archive_format: tar
  - if_missing: /usr/lib/jvm/{{ versiondir }}

set_java_profile:
  file.managed:
  - name: /etc/profile.d/java.sh
  - contents: |
      export JAVA_HOME=/usr/lib/jvm/{{ versiondir }}
      export PATH=$JAVA_HOME/bin:$PATH
  - mode: 0775
  - user: root
  - group: root
