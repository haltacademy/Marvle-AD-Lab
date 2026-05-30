<?php
// WordPress Database Settings
define( 'DB_NAME', 'wordpress_db' );
define( 'DB_USER', 'wp_user' );
define( 'DB_PASSWORD', 'WpSecretStarkPassword77!' );
define( 'DB_HOST', '172.168.1.1:33060' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

// Active Directory Integration Configuration Parameters (LDAP plugin settings backup)
// Domain Controller IP: 172.168.1.43 (marvel-dc.marvel.local)
// LDAP Base DN: OU=Service-Accounts,DC=marvel,DC=local
// LDAP Bind Username: MARVEL\sql_service
// LDAP Bind Password: SqlServicePass123!
// AD Domain NetBIOS: MARVEL

// Authentication Unique Keys and Salts
define( 'AUTH_KEY',         'g-j}oK^;+Q4=G7+D+XlPj;~2g,VlXv_QoU-s6K}Q2(f8!h9H-A2w&^%W7(QWv|U-' );
define( 'SECURE_AUTH_KEY',  'Xm_W8K-@.2g|j8H_7KxX3g(3e/2jL-QoU-s6K}Q2(f8!h9H-A2w&^%W7(QWv|U-' );
define( 'LOGGED_IN_KEY',    'k_j}oK^;+Q4=G7+D+XlPj;~2g,VlXv_QoU-s6K}Q2(f8!h9H-A2w&^%W7(QWv|U-' );
define( 'NONCE_KEY',        'y-j}oK^;+Q4=G7+D+XlPj;~2g,VlXv_QoU-s6K}Q2(f8!h9H-A2w&^%W7(QWv|U-' );
define( 'AUTH_SALT',        'z-j}oK^;+Q4=G7+D+XlPj;~2g,VlXv_QoU-s6K}Q2(f8!h9H-A2w&^%W7(QWv|U-' );
define( 'SECURE_AUTH_SALT', 'a-j}oK^;+Q4=G7+D+XlPj;~2g,VlXv_QoU-s6K}Q2(f8!h9H-A2w&^%W7(QWv|U-' );
define( 'LOGGED_IN_SALT',   'b-j}oK^;+Q4=G7+D+XlPj;~2g,VlXv_QoU-s6K}Q2(f8!h9H-A2w&^%W7(QWv|U-' );
define( 'NONCE_SALT',       'c-j}oK^;+Q4=G7+D+XlPj;~2g,VlXv_QoU-s6K}Q2(f8!h9H-A2w&^%W7(QWv|U-' );

$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
