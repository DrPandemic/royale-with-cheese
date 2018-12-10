#!/bin/sh

# Starts cron for acme.sh renewal
crond

if [ ! -f /etx/nginx/ssl/cert.pem ]
then
    # Generates self-signed cert to be able to boot nginx without the "real" cert from let's encrypt
    openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem -days 365 -subj '/CN=auctiontotem.com' -nodes

    nginx

    ~/.acme.sh/acme.sh --issue -d auctiontotem.com -d www.auctiontotem.com -w /var/www/letsencrypt
    ~/.acme.sh/acme.sh --install-cert -d auctiontotem.com \
                       --key-file       /etc/nginx/ssl/key.pem  \
                       --fullchain-file /etc/nginx/ssl/cert.pem \
                       --reloadcmd     "nginx -s reload"
else
    nginx
fi

tail -f /var/log/nginx/access.log
