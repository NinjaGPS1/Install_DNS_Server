#!/bin/bash

# Install BIND9 DNS server
sudo apt-get update
sudo apt-get install -y bind9

# Configure BIND9 DNS server
sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.orig

sudo tee /etc/bind/named.conf.options << EOF
options {
    directory "/var/cache/bind";

    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    dnssec-validation auto;

    auth-nxdomain no; # conform to RFC1035
    listen-on-v6 { any; };
};
EOF

sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.orig

sudo tee /etc/bind/named.conf.local << EOF
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
};

zone "0.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192";
};
EOF

sudo cp /etc/bind/db.local /etc/bind/db.example.com

sudo tee /etc/bind/db.example.com << EOF
\$TTL    604800
@       IN      SOA     ns1.example.com. admin.example.com. (
                      1         ; Serial
                 604800         ; Refresh
                  86400         ; Retry
                2419200         ; Expire
                 604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.example.com.
@       IN      A       192.168.0.2
ns1     IN      A       192.168.0.2
www     IN      A       192.168.0.3
EOF

sudo cp /etc/bind/db.127 /etc/bind/db.192

sudo tee /etc/bind/db.192 << EOF
\$TTL    604800
@       IN      SOA     ns1.example.com. admin.example.com. (
                      2         ; Serial
                 604800         ; Refresh
                  86400         ; Retry
                2419200         ; Expire
                 604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.example.com.
2       IN      PTR     ns1.example.com.
3       IN      PTR     www.example.com.
EOF

# Restart BIND9 DNS server
sudo systemctl restart bind9
