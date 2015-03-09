#!/bin/bash

SERVER_NAME=${SERVER_NAME:-"wordpress.test.org"}
DB_USER=${DB_USER:-"dbuser"}
DB_PASSWORD=${DB_PASSWORD:-"secretpassword"}
DB_HOST=${DB_HOST:-"database"}
DB_TABLE_PREFIX=${DB_TABLE_PREFIX:-"wp_"}

AUTH_KEY=${AUTH_KEY:-"1234590QWERTYUIOPASDFGHJKLQWERTYUI"}
SECURE_AUTH_KEY=${SECURE_AUTH_KEY:-"1234590QWERTYUIOPASDFGHJKLQWERTYUI"}
LOGGED_IN_KEY=${LOGGED_IN_KEY:-"1234590QWERTYUIOPASDFGHJKLQWERTYUI"}
NONCE_KEY=${NONCE_KEY:-"1234590QWERTYUIOPASDFGHJKLQWERTYUI"}
AUTH_SALT=${AUTH_SALT:-"1234590QWERTYUIOPASDFGHJKLQWERTYUI"}
SECURE_AUTH_SALT=${SECURE_AUTH_SALT:-"1234590QWERTYUIOPASDFGHJKLQWERTYUI"}
LOGGED_IN_SALT=${LOGGED_IN_SALT:-"1234590QWERTYUIOPASDFGHJKLQWERTYUI"}
NONCE_SALT=${NONCE_SALT:-"1234590QWERTYUIOPASDFGHJKLQWERTYUI"}

chown -R nginx:nginx /var/www/wp-contents

cat >/var/www/wp-config.php<<EOF
<?php
/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, and ABSPATH. You can find more information by visiting
 * {@link http://codex.wordpress.org/Editing_wp-config.php Editing wp-config.php}
 * Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

define('DISALLOW_FILE_EDIT', true);

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', '$DB_NAME');

/** MySQL database username */
define('DB_USER', '$DB_USER');

/** MySQL database password */
define('DB_PASSWORD', '$DB_PASSWORD');

/** MySQL hostname */
define('DB_HOST', '$DB_HOST');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '$AUTH_KEY');
define('SECURE_AUTH_KEY',  '$SECURE_AUTH_KEY');
define('LOGGED_IN_KEY',    '$LOGGED_IN_KEY');
define('NONCE_KEY',        '$NONCE_KEY');
define('AUTH_SALT',        '$AUTH_SALT');
define('SECURE_AUTH_SALT', '$SECURE_AUTH_SALT');
define('LOGGED_IN_SALT',   '$LOGGED_IN_SALT');
define('NONCE_SALT',       '$NONCE_SALT');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
\$table_prefix  = '$DB_TABLE_PREFIX';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
EOF


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
