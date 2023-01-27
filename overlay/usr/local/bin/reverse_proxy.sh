#!/bin/bash
#v1.10

username=$1
sslport=$2
server=$3

echo $username

#Create Apache reverse proxy
apacheconfigfile=/etc/apache2/sites-available/$username.conf
domainappend=.sagetea.ai.conf
domainname_filename=$username$domainappend
ssl_filename=$username-ssl$domainappend
apachedomainnameconfigfile=/etc/apache2/sites-available/$domainname_filename
apachesslconfigfile=/etc/apache2/sites-available/$ssl_filename

#Domain name virtual host
sudo echo "<VirtualHost *:80>" > $apachedomainnameconfigfile
sudo echo "    ServerName $username.sagetea.ai" >> $apachedomainnameconfigfile
sudo echo "" >> $apachedomainnameconfigfile
sudo echo "    ServerAlias www.$username.sagetea.ai" >> $apachedomainnameconfigfile
sudo echo "    Redirect / https://$username.sagetea.ai/" >> $apachedomainnameconfigfile
sudo echo "</VirtualHost>" >> $apachedomainnameconfigfile

#SSL virtual host
sudo echo "<VirtualHost *:443>" > $apachesslconfigfile
sudo echo "    SSLProxyEngine on" >> $apachesslconfigfile
sudo echo "    ServerName $username.sagetea.ai" >> $apachesslconfigfile
sudo echo "    ProxyPass / http://$server:$sslport/" >> $apachesslconfigfile
sudo echo "    ProxyPassReverse / http://$server:$sslport/" >> $apachesslconfigfile
sudo echo "    ErrorLog ${APACHE_LOG_DIR}/error.log" >> $apachesslconfigfile
sudo echo "    CustomLog ${APACHE_LOG_DIR}/access.log combined" >> $apachesslconfigfile
sudo echo "</VirtualHost>" >> $apachesslconfigfile

sudo a2enmod headers
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod ssl

sudo a2ensite $domainname_filename
sudo a2ensite $ssl_filename

service apache2 reload

exit 0