#!/bin/bash
if [ $# -lt 1 ]; then
	echo "Usage: $0 domainname"
	exit
fi
domainname=$1
echo domainname:$domainname
curl https://get.acme.sh |sh
source ~/.bashrc

if [ ! -e ~/.acme.sh/${domainname}_ecc/fullchain.cer ]; then
	#systemctl stop nginx
	#/etc/init.d/nginx stop
	~/.acme.sh/acme.sh --issue -d $domainname -w /usr/share/nginx/html -k ec-256
fi

mkdir /etc/v2ray/
~/.acme.sh/acme.sh --installcert -d $domainname --fullchainpath /etc/v2ray/v2ray.cer --keypath /etc/v2ray/v2ray.key --ecc

realdir=`pwd ~`
num=`crontab -l|grep installcert|wc -l`
if [ $num -lt 1 ]; then
      crontab -l | {
        cat
        echo "30 0 * * * $realdir/.acme.sh/acme.sh --installcert -d $domainname --fullchainpath /etc/v2ray/v2ray.cer --keypath /etc/v2ray/v2ray.key --reloadCmd '/usr/sbin/nginx -s reload' --ecc > /dev/null"
      } | crontab

fi
