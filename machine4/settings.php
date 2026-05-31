<?php
$databases = array (
  'default' => 
  array (
    'default' => 
    array (
      'database' => 'drupal_db',
      'username' => 'drupal_user',
      'password' => 'DrupalSecretRogersPassword88!',
      'host' => '172.168.1.1',
      'port' => '33060',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);

// Active Directory Integration Configuration Parameters (LDAP settings backup)
// Domain Controller IP: 172.168.1.43 (marvel-dc.marvel.local)
// LDAP Base DN: OU=Domain-Users,DC=marvel,DC=local
// LDAP Bind Username: MARVEL\peterparker
// LDAP Bind Password: SpideyWebSlinger123!
// AD Domain NetBIOS: MARVEL

$update_free_access = FALSE;
$drupal_hash_salt = 'StarkIndustriesSecretSaltForPasswordHashing2026';
ini_set('session.gc_probability', 1);
ini_set('session.gc_divisor', 100);
ini_set('session.gc_maxlifetime', 200000);
ini_set('session.cookie_lifetime', 2000000);
$conf['theme_default'] = 'bartik';
$conf['clean_url'] = 1;
