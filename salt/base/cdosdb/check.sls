

{% if salt['mysql.db_exists']('sphereds', {'user': 'root', 'password': pillar.cdos.mysql.rootpass }) %}

{% endif %}