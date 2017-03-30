

{% set keylist = salt.pillar.get('apt:keys:deprecated', {}) -%}
{% for keyname, keyfile in keylist|dictsort -%}
#
# Remove keys if flagged
#
{{ keyname }}_absent:
  alchemy.key_absent:
    - name: {{ keyname }}
    - file: {{ keyfile }}
    - watch_in:
      - cmd: apt_update

{% endfor -%}

# set default keys and add role dependant keys
{% set keylist = salt.pillar.get('apt:keys:default', {}) -%}
{% for role in grains.roles -%}
{%- set keylist = salt.pillar.get("apt:keys:{0}".format(role), keylist, True) %}
{% endfor -%}
#
# Add keys if not avail
#
{% for keyname, keyfile in keylist|dictsort -%}

{{ keyname }}_keycheck:
  alchemy.key_exists:
    - name: {{ keyname }}
    - file: {{ keyfile }}
    - source: salt://core/files/apt/keys/{{ keyfile }}
    - watch_in:
      - cmd: apt_update

{% endfor -%}

#
# Delete deprecated apt sources snippets if still existant
#
{% set deprecates = salt.pillar.get('apt:depricated', {}) %}
{% for sourcelist in deprecates -%}

/etc/apt/sources.list.d/{{ sourcelist }}:
  file.absent:
    - name: /etc/apt/sources.list.d/{{ sourcelist }}
    - watch_in:
      - cmd: apt_update

{% endfor -%}

#
# Create apt sources in /etc/apt/sources.list and sources.list.d
#
{% set sources = salt.pillar.get('apt:sources', {}) -%}
{% for id in sources %}
{# Set default sourcespath to the snippet directory #}
{% set sourcespath = '/etc/apt/sources.list.d' -%}
{% if id == 'main' -%}
{# Handle special case /etc/apt/sources.list #}
{% set sourcespath = '/etc/apt' -%}
{% endif -%}

# Create the file
{{ id }}_repo:
  file.managed:
    - name: {{ sourcespath }}/{{ id }}.list
    - source: salt://core/files/apt/apt.tpl
    - template: jinja
    - context:
      pillar_id: apt:sources:{{ id }}
    - watch_in:
      - cmd: apt_update
{%- endfor %}

{% set aptextras = salt.pillar.get('extras:apt', False) %}

{% if not aptextras %}
extras_removed_at_once:
  cmd.run:
    - name: rm -f /etc/apt/sources.list.d/extras.*
    - unless:
        - test /etc/apt/sources.list.d/extras.*
    - watch_in:
      - cmd: apt_update
{% else %}
{% for filename, content in aptextras.iteritems() %}
{% if content is none %}
remove_empty_file_{{ filename }}:
  file.absent:
    - name: /etc/apt/sources.list.d/extras.{{ filename }}.list
    - watch_in:
      - cmd: apt_update
{% else -%}
{{ filename }}_extra_repos:
  file.managed:
  - name: /etc/apt/sources.list.d/extras.{{ filename }}.list
  - contents:
    - {{ content }}
  - watch_in:
    - cmd: apt_update
{% endif -%}
{% endfor %}
{% endif %}

#
# Delete depricated config files if still existant
#
{% set exconfigs = salt['pillar.get']('apt:exconfigs', {}) %}
{%- for exconfig in exconfigs %}

/etc/apt/apt.conf.d/{{ exconfig }}:
  file.absent:
  - name: /etc/apt/apt.conf.d/{{ exconfig }}
  - watch_in:
    - cmd: apt_update
{%- endfor %}

#
# Create apt configs in /etc/apt/apt.conf.d
#
{% set configs = salt['pillar.get']('defaults:apt:configs', {}) %}
{%- for id in configs %}

{{ id }}_config:
  file.managed:
    - name: /etc/apt/apt.conf.d/{{ id }}
    - source: salt://core/files/apt/apt.tpl
    - template: jinja
    - context:
      pillar_id: apt:configs:{{ id }}
{%- endfor %}

apt_update:
  cmd.run:
    - name: apt-get -qq update
