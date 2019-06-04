#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Usage: $0 domainname"
	exit
fi
domainname=$1
echo domainname:$domainname
apt-get -y install socat nginx
curl https://get.acme.sh |sh
source ~/.bashrc

if [ ! -e ~/.acme.sh/${domainname}_ecc/fullchain.cer ]; then
	#systemctl stop nginx
	#/etc/init.d/nginx stop
	~/.acme.sh/acme.sh --issue -d $domainname -w /var/www/html -k ec-256
fi
if [ ! -e /etc/v2ray/nginxtls.conf ]; then
	cat <<EOF >/etc/v2ray/nginxtls.conf
listen 443 ssl default_server;
listen [::]:443 ssl default_server;
ssl_certificate /etc/v2ray/v2ray.cer;
ssl_certificate_key /etc/v2ray/v2ray.key;
location /msg   {
	proxy_redirect off;
	proxy_pass http://127.0.0.1:10000;
	proxy_http_version 1.1;
	proxy_set_header Upgrade \$http_upgrade;
	proxy_set_header Connection "upgrade";
	proxy_set_header Host \$http_host;
}
EOF
fi
nginxconf='/etc/nginx/sites-available/default'
sed -i -e 's/^\([ \t]*\)ssl_certificate/\1#ssl_certificate/' -e 's/^\([ \t]*\)include snippets/\1#include snippets/' -e '/^\([ \t]*\)include \/etc\/v2ray/d' -e '/root \/var\/www\/html/i\include \/etc\/v2ray\/nginxtls.conf;' $nginxconf

~/.acme.sh/acme.sh --installcert -d $domainname --fullchainpath /etc/v2ray/v2ray.cer --keypath /etc/v2ray/v2ray.key --ecc
systemctl restart nginx
/etc/init.d/nginx start

realdir=`pwd ~`
num=`crontab -l|grep installcert|wc -l`
if [ $num -lt 1 ]; then
      crontab -l | {
        cat
        echo "30 0 * * * $realdir/.acme.sh/acme.sh --installcert -d $domainname --fullchainpath /etc/v2ray/v2ray.cer --keypath /etc/v2ray/v2ray.key --reloadCmd '/usr/sbin/nginx -s reload' --ecc > /dev/null"
      } | crontab
	
fi
