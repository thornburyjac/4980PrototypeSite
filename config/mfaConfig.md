# Here are the files you will need for the mfa website containerization

## config file: /etc/nginx/sites-available/default

```text
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    # Redirect all HTTP traffic to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name _;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    # Other SSL configuration directives can go here

        location / {
                root /var/www/html;
                try_files $uri $uri/ =404;
        }
}

server {
    listen 444 ssl;
    listen [::]:444 ssl;
    server_name _;

    root /var/www/html/authreq;

    index obiwan.html;


    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    ssl_client_certificate /home/ubuntu/testclientcert/testuser.crt;
    ssl_verify_client on;
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;
}
```

## self signed cert: /etc/ssl/certs/nginx-selfsigned.crt

```text
-----BEGIN CERTIFICATE-----
MIIDazCCAlOgAwIBAgIUIIAq0chl2x1lhS+aWsFOI3/VYFkwDQYJKoZIhvcNAQEL
BQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM
GEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yNDA5MDIxNzMwNTNaFw0yNTA5
MDIxNzMwNTNaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw
HwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCwfnC/GqXEQME7G6Yn6luSgUBSRIViw0e83O9GmmqY
yxjNd3bbCpbzgV7JgfZ9m/hRwkleUSUJ4BixF+CuujwgFhkWT3zbVsjRSJQo1Qt/
YBm0QZQI/VSRcJGuH6RnGfpo79ee4u4czIMvqOdLTm8+YweytwtgWFuIth4zCpAT
s6Kval25mK7cW7nowrgQO91WKIun8GtuoLVceu6daLjBaM7JwrW/tDdFBbZAotR+
gzJRvTB3BCs8hvMkJbNLkzQJsqlFObBJrKb66dYJeFV7iw6jk1pEsfDbl6bNLkzG
/K/Z5q/PYmLJv/Jd0QP0Jx/izT3AM/2sbBL6DJsacUvpAgMBAAGjUzBRMB0GA1Ud
DgQWBBSWvLjRh9vDmM8jmSEhZ82PNSIHDzAfBgNVHSMEGDAWgBSWvLjRh9vDmM8j
mSEhZ82PNSIHDzAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBC
14KjCHUy2GV7FNygfLHyrhhbqGiphZymx/E1OvDYn2cFRfA+MZeXbsRudkv74hNh
OQUh1nu1gmq3gJl863LWmFPxSgWHkSEiPIwkec20Yh2zDf2Z6tzdyU8wiJtoLtBc
lCOlESFfOcxqRiKR2QBGqQacGUcRZFMHPbBgyzunp2fzzRTi3DlWiVe6kk7a6p5U
4YJI4VD3U9HEi8lNlY8o83LJ36W7Lr/bqkCzALiCrKoeje5/+J2iqwg4kz9bZpzD
45MNEU5HAHaWPr1DV9P3F2o82BQsUwPNc547Tj0B08PETbYhNiBxInhe5TfRm8IK
Ms6iHAeIfcxQHkclxqB2
-----END CERTIFICATE-----
```

## self signed key: /etc/ssl/certs/nginx-selfsigned.key

```text
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCwfnC/GqXEQME7
G6Yn6luSgUBSRIViw0e83O9GmmqYyxjNd3bbCpbzgV7JgfZ9m/hRwkleUSUJ4Bix
F+CuujwgFhkWT3zbVsjRSJQo1Qt/YBm0QZQI/VSRcJGuH6RnGfpo79ee4u4czIMv
qOdLTm8+YweytwtgWFuIth4zCpATs6Kval25mK7cW7nowrgQO91WKIun8GtuoLVc
eu6daLjBaM7JwrW/tDdFBbZAotR+gzJRvTB3BCs8hvMkJbNLkzQJsqlFObBJrKb6
6dYJeFV7iw6jk1pEsfDbl6bNLkzG/K/Z5q/PYmLJv/Jd0QP0Jx/izT3AM/2sbBL6
DJsacUvpAgMBAAECggEABXvo06wfIVhXe+ypHIlD155fYnEm0AGzscX+ds5Axmk6
d9T+r9DS2oa5QcQdMpOimHgG9i+nngEJe+iMQt5rJabiqUWTWeeo/lqyi0/9w/d7
kchBVJk+iDlxci2Yycma4/6z2Bj+blovQPF9+dE4QvD2/8UqmcK/wEwHCZhfhvY0
uj1lksLQIrfrDGAhNWDjLCH/F/UT+fJXaXuvaUZJQNn7QmCCcEfRgI/LrMhuxd54
y0ONEUi6Drw2l4nXpH5dOjdQVTo9wgPxp/Z+VEZvpMwrORC97IFbdl9xyUpluwTq
qF88DbytKRhuFIchsZCFs+ILVtgZYoSFyi6inj5bGwKBgQDB/Xe/ZKHdBPNZeHag
XfCaiCV5vyp87Fhy5TtuKVBZzVFShX9aaUoF/pMP97U3f1hc9rcJqdxVcMmzigV5
RVNqw8U7FYMsT5o/iGrnC11iZTdrj0K9S4UjJVYLH6VPjNW4L19h8EnTAjhFdyER
Og+ElGlOcMv2N7628WvLjZn72wKBgQDo6TrDn76q9mXaojEVMqpVBsv5ev6rrAir
lbi0FLmA6IexOP+1RCu01EDt4KffZP+dBdSOvurHaRp7pR4Luk8B71sFlTasrQrd
ZUKiOiWAw0Ufc8/O0CPejciq/EWbohp8qAPlbXWNe32r7ynDLZrOV15r6k5zd5r6
quNuSJxkiwKBgHGz7FVNWaZfeXdOqVFT3mvlMvoKN5AjQ7CMdeoa4xLPykOxJbVL
k2yyC2bHjPsrdBKBNUW/vvqBcmf+lTjAjqU8fEUmVc1KFyH4BpjHy4OZygMMZFTp
h+7Sun0onk9jP/2GHsUb/1ljqrHkoogjXOcbyiGE8beucuVt2f3kUIYTAoGAEV4q
8qF731XGXJpRnKoNh4+dMDpauUR31QuyHUOaXaF5VN7SOpsdwzs8qEBjZEYsxXHE
2uwjp8EPp361kdxPve4yVGU/EXtJ3x6I7H33g/WLtv+01FAzDIp4Fz/+lM9uuDLz
L22NIYK+6U5JR/OjopVjRhrPxM57cQvDL9scRmcCgYBIQdC7cZeQSQ7bECub/+Qh
to3xevYNZWacDRpbwinA/+lS6NveVjkWYh9owpvzf0Sauh92O6sQcZq8eHh/o00D
S4fD5fyQYSxyWWFVgrfDlAphBOlki3oYYm4jcLkbLQzus48p232kyRiJ6MzoVFrz
6uJxAoYCADzZQPUUTZH4ig==
-----END PRIVATE KEY-----
```

## client certificate: /home/ubuntu/testclientcert/testuser.crt

```text
-----BEGIN CERTIFICATE-----
MIID/jCCAeYCAQEwDQYJKoZIhvcNAQELBQAwRTELMAkGA1UEBhMCQVUxEzARBgNV
BAgMClNvbWUtU3RhdGUxITAfBgNVBAoMGEludGVybmV0IFdpZGdpdHMgUHR5IEx0
ZDAeFw0yNDA5MjUxODQ0MDFaFw0yNTA5MjUxODQ0MDFaMEUxCzAJBgNVBAYTAkFV
MRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRz
IFB0eSBMdGQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCzuv4Yzach
cKFo09K7XXaJlXhkJPaiDHfnzFZZ0f0VzmbPMul3aGvYZW7XRPVO+735QaG39L+i
EH9fBjvWeUm6DVFmzW1XJWCZp9mtKmdyj2bYsRZ2WkclcJNpcurNrXPbTgZa09nY
9BJRMQQoC5JxAlrzY73lOpsH2LQc60gnCqh/6uAcKf6Q85hmvXpYUF97o7Qj+wQl
WdbmSY2N57MlCUsJKQ/R7En1bLjwvhfNPKdMXtr0cErqHekqAmmW9l3KSuAGpcdM
Ng38QokcASQBrb8NYuWLAgK/EDzaRU9oMqGOqqMuNRSgqkkKkd/Lk1K9B9OTBgQo
66PlKDrCGMhhAgMBAAEwDQYJKoZIhvcNAQELBQADggIBANWAFWlOPmd0pz3wm+H0
+TX68jrFMZR6Smle7R8mxWLSPoqs0S4mKR4cy2/xuELMYh8gbvkROwAKaNhgZMFS
AZFbVky/5EM131G///IsqDDibGVhXF3EmOW83uWENe7ONbqKoVv4hJ2em7C20AWR
GS1QPgDNPT3mma9XzNqudBqPq1ELELffwtbK/O5goeO+lxZW+5wxLDE8fEi6IBsU
8X7HNpBm/BBUnUV/MgkNhJMINBGkTlwck/z9ffZNq69fsrPo78q3+cp5FxKfNS0H
zbRgKLeofOGajIUiHO36sublhOIGupV842gDc49xK4LuErVGbQGKzJyqXSG0/za/
Ec4HkpyU5b5azvO9MYIabbeHAH2ujKGJ/coyr0Q53IHEV7QYr8VRUZPojUoTZ6sG
qNeYe8F1+TqWUO3au7iKxbBCr4iKiEFXBE6RJyOZ/t1J6MaaLQ1G4LdWMILzkJIr
46oG2My/XL36ivbGk4zhaHc26t13ORwU68p6o1gsrGpRgwJV4X5jkR6cdCVWYkMO
HL2F/xMWk1D7wzKY0zsqsTNHc5xJJID4eN+Z6mtkehxPIsoFdRHXykNJ6wCiHhe7
5H1KJrp8yAOVXpmvqn9nWVrvgwAFCf8LPBGYjY+gZKdBfCmt2l9GfayLn/l2ttrj
9MzE7APspot91Pqwh98REwiB
-----END CERTIFICATE-----
```

## basic auth file: /etc/nginx/.htpasswd

```text
obiwan:$apr1$rp8DljAT$WytmwLRSMXk0uLaiAsuSR/
```
