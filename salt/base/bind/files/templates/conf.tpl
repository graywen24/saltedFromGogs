//
// BIND zone config file for the {{ zone }} domain
//
// {{ pillar.defaults.hint }}
//

zone "{{ zone }}" {
    type master;
    file "/etc/bind/zones/{{ type }}/{{ zone }}.db";
};
