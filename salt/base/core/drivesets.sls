
# find drivesets for the current host
{% set drivesetnames = salt['pillar.get']("hosts:%s:drivesets"|format(grains.nodename), []) %}

# only execute on machines with a drivesets
{% if drivesetnames|count > 0 -%}

# ensure the partitioning tool is installed on a host
drivesets_ensure_installed:
  pkg.latest:
  - pkgs:
    - parted

{% for drivesetname in drivesetnames -%}
{% for drive, driveconfig in salt['pillar.get']("drivesets:" + drivesetname, {}).items() -%}
{% for part, partconfig in driveconfig.partitions.items() -%}

# partition the drive if nessessary
{{ drive }}{{ part }}_{{ partconfig.partlabel }}_created:
  blockdev.created:
    - name: /dev/{{ drive }}{{ part }}
    - start: {{ partconfig.start }}
    - end: {{ partconfig.end }}
    - table: {{ driveconfig.table }}
    - partlabel: {{ partconfig.partlabel }}

# format the partition if needed
{{ drive }}{{ part }}_{{ partconfig.partlabel }}_formatted:
  blockdev.formatted:
    - name: /dev/{{ drive }}{{ part }}
    - fs_type: {{ partconfig.fs }}
    - require:
      - blockdev: {{ drive }}{{ part }}_{{ partconfig.partlabel }}_created

{% endfor -%}
{% endfor -%}
{% endfor -%}
{% endif -%}
