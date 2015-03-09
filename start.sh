#!/bin/bash

SERVER_NAME=${SERVER_NAME:-"wordpress.test.org"}

chown -R nginx:nginx /var/www/

sed -i 's/allow_url_fopen = [A-z.-]*/allow_url_fopen = Off/g' /etc/php.ini
sed -i 's/;cgi.fix_pathinfo = 1*/cgi.fix_pathinfo = 0/g' /etc/php.ini

cat >/etc/nginx/conf.d/wordpress.conf<<EOF
server {
        server_name $SERVER_NAME;
        root /var/www;
        
        index index.php;
 
        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }
 
        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }
 
        location / {
                try_files \$uri \$uri/ /index.php?\$args;
        }
 
        location ~ \.php$ {
                fastcgi_intercept_errors on;
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_index index.php;
                include fastcgi_params;
        }
 
        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
}

EOF

supervisord -c /etc/supervisord.conf
