<?php
define('WP_INSTALLING', true);
require_once '/var/www/html/wp-load.php';
require_once '/var/www/html/wp-admin/includes/upgrade.php';

if (!is_blog_installed()) {
    wp_install(
        'Stark Industries Internal Portal',
        'admin',
        'StarkWpAdminPassword99!',
        'admin@marvel.local',
        true
    );
    echo "WordPress database and tables installed successfully.\n";
} else {
    echo "WordPress is already installed.\n";
}
?>
