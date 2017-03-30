;
; BIND soa data file for the {{ zone }} domain
;
; {{ pillar.defaults.hint }}
;

@ IN SOA localhost. root.localhost. (
    {{ "%12s"|format(serial) }} ; Serial
          604800 ; Refresh
           86400 ; Retry
         2419200 ; Expire
          604800 ; Negative Cache TTL
)
