{% set records = salt.pillar.get('zones:' + zone) -%}
;
; BIND data file for the {{ zone }} domain
;
; {{ pillar.defaults.hint }}
;

$ORIGIN {{ zone }}.
$TTL 86400   ; 1 day

; make bind include the soa record
$INCLUDE /etc/bind/zones/arpa/{{ zone }}.soa.db

{% for record in records -%}
{{ record }}
{% endfor -%}
