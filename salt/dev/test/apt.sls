# install the public keys for all repos we include
{% if 'repo' in grains.roles -%}
{% set keyblocks = salt['pillar.get']('apt:keys', {}) -%}
{% set keylist = salt['pillar.get']('apt:keys:default', {}) -%}
{% for role, data in keyblocks|dictsort -%}
{% set keylist = salt['pillar.get']('apt:keys:{0}'.format(role), keylist, True) -%}
{% endfor -%}
#
# {{ keylist }}
#

{% for keyname, keyfile in keylist|dictsort -%}

{{ keyname }}_keycheck:
  alchemy.key_exists:
    - name: {{ keyname }}
    - file: {{ keyfile }}
    - keyring: aptlykeys.gpg
    - source: salt://core/files/apt/keys/{{ keyfile }}
    - saltenv: base

{% endfor -%}
{% endif -%}


{% set keylist = salt['pillar.get']('apt:keys:default', {}) -%}
{% for role in grains.roles -%}
{% set keylist = salt['pillar.get']('apt:keys:{0}'.format(role), keylist, True) -%}
{% endfor -%}
#
# Add keys if not avail
#

{% for keyname, keyfile in keylist|dictsort -%}

{{ keyname }}_apt_keycheck:
  alchemy.key_exists:
    - name: {{ keyname }}
    - file: {{ keyfile }}
    - source: salt://core/files/apt/keys/{{ keyfile }}
    - saltenv: base

{% endfor -%}
