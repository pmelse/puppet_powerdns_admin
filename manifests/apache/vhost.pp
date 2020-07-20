# == Class: powerdns_admin::apache::vhost
#
# Sets up an apache::vhost to run powerdns_admin,
# and writes an appropriate wsgi.py from template.
#
# === Parameters
#
# Document parameters here.
#
# [*vhost_name*]
#   (string) The vhost ServerName.
#   No default.
#
# [*wsgi_aliases*]
#   (string) WSGI script alias source
#   Default: { '/' => '/srv/powerdns_admin/powerdns_admin/wsgi.py'}
#
# [*port*]
#   (int) Port for the vhost to listen on.
#   Defaults to 5000.
#
# [*ssl*]
#   (bool) If vhost should be configured with ssl
#   Defaults to false
#
# [*ssl_cert*]
#   (string, absolute path) Path to server SSL cert
#   No default.
#
# [*ssl_key*]
#   (string, absolute path) Path to server SSL key
#   No default.
#
# [*threads*]
#   (int) Number of WSGI threads to use.
#   Defaults to 5
#
# [*user*]
#   (string) WSGI daemon process user, and daemon process name
#   Defaults to 'powerdns_admin' ($::powerdns_admin::params::user)
#
# [*group*]
#   (int) WSGI daemon process group owner, and daemon process group
#   Defaults to 'powerdns_admin' ($::powerdns_admin::params::group)
#
# [*basedir*]
#   (string) Base directory where to build powerdns_admin vcsrepo and python virtualenv.
#   Defaults to '/srv/powerdns_admin' ($::powerdns_admin::params::basedir)
#
# [*override*]
#   (string) Sets the Apache AllowOverride value
#   Defaults to 'None' ($::powerdns_admin::params::apache_override)
#
# [*enable_ldap_auth]
#   (bool) Whether to enable LDAP auth
#   Defaults to False ($::powerdns_admin::params::enable_ldap_auth)
#
# [*ldap_bind_dn]
#   (string) LDAP Bind DN
#   No default ($::powerdns_admin::params::ldap_bind_dn)
#
# [*ldap_bind_password]
#   (string) LDAP password
#   No default ($::powerdns_admin::params::ldap_bind_password)
#
# [*ldap_url]
#   (string) LDAP connection string
#   No default ($::powerdns_admin::params::ldap_url)
#
# [*ldap_bind_authoritative]
#   (string) Determines if other authentication providers are used
#            when a user can be mapped to a DN but the server cannot bind with the credentials
#   No default ($::powerdns_admin::params::ldap_bind_authoritative)
#
# [*ldap_require_group]
#   (bool) LDAP group to require on login
#   Default to False ($::powerdns_admin::params::ldap_require_group)
#
# [*$ldap_require_group_dn]
#   (string) LDAP group DN for LDAP group
#   No default
class powerdns_admin::apache::vhost (
  String $vhost_name,
  String $docroot                           = '/srv/powerdnsadmin',
  Dict $wsgi_aliases                        = {'/' => '/srv/powerdns_admin/powerdns_admin/wsgi.py'},
  String $wsgi_daemon_process               = 'powerdnsadmin',
  String $wsgi_process_group                = 'powerdnsadmin',
  Integer $port                             = 5000,
  Boolean $ssl                              = false,
  Optional[Stdlib::AbsolutePath] $ssl_cert  = undef,
  Optional[Stdlib::AbsolutePath] $ssl_key   = undef,
  Integer $threads                          = 5,
  String $user                              = $powerdns_admin::params::user,
  String $group                             = $powerdns_admin::params::group,
  Stdlib::AbsolutePath $basedir             = $powerdns_admin::params::basedir,
  Optional[String] $override                          = $powerdns_admin::params::apache_override,
  Boolean $enable_ldap_auth                 = $powerdns_admin::params::enable_ldap_auth,
  Optional[String] $ldap_bind_dn            = undef,
  Optional[String] $ldap_bind_password      = undef,
  Optional[String] $ldap_url                = undef,
  Optional[String] $ldap_bind_authoritative = undef,
  Boolean $ldap_require_group               = $powerdns_admin::params::ldap_require_group,
  Optional[String] $ldap_require_group_dn   = undef,
  Hash $custom_apache_parameters            = {},
) inherits ::powerdns_admin::params {

  $docroot = "${basedir}/powerdns_admin"

  $wsgi_script_aliases = {
    "${wsgi_aliases}" => "${docroot}/wsgi.py",
  }

  $wsgi_daemon_process_options = {
    threads => $threads,
    group   => $group,
    user    => $user,
  }

  file { "${docroot}/wsgi.py":
    ensure  => present,
    content => template('powerdns_admin/wsgi.py.erb'),
    owner   => $user,
    group   => $group,
    require => [
      User[$user],
      Vcsrepo[$docroot],
    ],
  }

  if $enable_ldap_auth {
    $ldap_additional_includes = [ "${powerdns_admin::params::apache_confd}/powerdns_admin-ldap.part" ]
    $ldap_require = File["${powerdns_admin::params::apache_confd}/powerdns_admin-ldap.part"]
    file { 'powerdns_admin-ldap.part':
      ensure  => present,
      path    => "${powerdns_admin::params::apache_confd}/powerdns_admin-ldap.part",
      owner   => 'root',
      group   => 'root',
      content => template('powerdns_admin/apache/ldap.erb'),
      require => File["${docroot}/wsgi.py"],
      notify  => Service[$powerdns_admin::params::apache_service],
    }
  }
  else {
    $ldap_additional_includes = undef
    $ldap_require = undef
  }
  ::apache::vhost { $vhost_name:
    port                        => $port,
    docroot                     => $docroot,
    ssl                         => $ssl,
    ssl_cert                    => $ssl_cert,
    ssl_key                     => $ssl_key,
    additional_includes         => $ldap_additional_includes,
    wsgi_daemon_process         => $user,
    wsgi_process_group          => $group,
    wsgi_script_aliases         => $wsgi_script_aliases,
    wsgi_daemon_process_options => $wsgi_daemon_process_options,
    override                    => $override,
    require                     => [ File["${docroot}/wsgi.py"], $ldap_require ],
    notify                      => Service[$powerdns_admin::params::apache_service],
    *                           => $custom_apache_parameters,
  }
  File["${basedir}/powerdns_admin/settings.py"] ~> Service['httpd']
}
