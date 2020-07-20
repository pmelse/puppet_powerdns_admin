# Class: powerdns_admin::mysql::mysql
#
#
class powerdns_admin::mysql::mysql (
  String $mysql_powerdnsadmin_password = undef,
  String $mysql_powerdnsadmin_user = undef,
  String $mysql_powerdnsadmin_database = undef,
  String $mysql_powerdnsadmin_host = 'localhost',
  Tuple $mysql_powerdnsadmin_grant = ['ALL'],
  ) inherits powerdns_admin::params {
  mysql::db { $mysql_powerdnsadmin_database:
  user     => $mysql_powerdnsadmin_user,
  password => $mysql_powerdnsadmin_password,
  host     => $mysql_powerdnsadmin_host,
  grant    => $mysql_powerdnsadmin_grant,
}
}
