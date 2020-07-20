# Class: powerdns_admin::mysql::mysql
#
#
class powerdns_admin::mysql::mysql (
  String $mysql_root_password = undef,
  $override_options           = {},
  ) inherits powerdns_admin::params {
  file { '/srv/mysql':
    ensure => 'directory',
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0771',
  }
  $override_options = {
    'mysqld' => {
      'bind-address'    => "${facts}['network']",
      'datadir'         => '/srv/mysql',
      'log_bin'         => '/srv/mysql.bin.log',
      'max_binlog_size' => '64424509440',
    }
  }

  # $mysql_config = lookup( { 'name' => 'mysql' } )


  class { '::mysql::server':
    root_password           => $powerdns_admin::mysql_root_password,
    remove_default_accounts => true,
    override_options        => $override_options
  }

}
