python-gnupg:
  pkg.latest: []

# install the public keys for all repos we include
{% if 'repo' in grains.roles -%}
{% set keylists = salt.alchemy.apt_key_list() -%}

# Remove all deprecated keys
#
{% for keyname, keyfile in keylists.deprecated|dictsort -%}
{{ keyname }}_key_absent:
  alchemy.key_absent:
    - name: {{ keyname }}
    - file: {{ keyfile }}
    - keyring: trustedkeys.gpg

{% endfor -%}

#
# Install all keys for known repos in the users aptly keyring
#
{% for keyname, keyfile in keylists.installed|dictsort -%}
{{ keyname }}_key_installed:
  alchemy.key_exists:
    - name: {{ keyname }}
    - file: {{ keyfile }}
    - keyring: trustedkeys.gpg
    - source: salt://core/files/apt/keys/{{ keyfile }}

{% endfor -%}
{% endif -%}

ensure_key:
  gpg.skey_present:
    - name: 249C4A666CBE5D2D
    - text: |
        -----BEGIN PGP PRIVATE KEY BLOCK-----
        Version: GnuPG v1

        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
        BB/oMCsUYbTpCh8FevZJ4zWsWE6FEeN4jTI=
        =mHk1
        -----END PGP PRIVATE KEY BLOCK-----
