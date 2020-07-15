# == Class: powerdns_admin::apache::conf
#
# Creates an entry in your apache configuration directory
# to run powerdns_admin server-wide (i.e. not in a vhost).
#
# === Parameters
#
# Document parameters here.
#
# [*wsgi_alias*]
#   (string) WSGI script alias source
#   Default: '/powerdns_admin'
#
# [*threads*]
#   (int) Number of WSGI threads to use.
#   Defaults to 5
#
# [*max_reqs*]
#   (int) Limit on number of requests allowed to daemon process
#   Defaults to 0 (no limit)
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
#   (string) Determines if other authentication providers are used when a user can be mapped to a DN but the server cannot bind with the credentials
#   No default ($::powerdns_admin::params::ldap_bind_authoritative)
#
# [*ldap_require_group]
#   (bool) LDAP group to require on login
#   Default to False ($::powerdns_admin::params::ldap_require_group)
#
# [*$ldap_require_group_dn]
#   (string) LDAP group DN for LDAP group
#   No default
#
# === Notes:
#
# Make sure you have purge_configs set to false in your apache class!
#
# This runs the WSGI application with a WSGIProcessGroup of $user and
# a WSGIApplicationGroup of %{GLOBAL}.
#
class powerdns_admin::apache::conf (
  String $wsgi_alias                        = '/powerdns_admin',
  Integer $threads                          = 5,
  Integer $max_reqs                         = 0,
  String $user                              = $powerdns_admin::params::user,
  String $group                             = $powerdns_admin::params::group,
  Stdlib::AbsolutePath $basedir             = $powerdns_admin::params::basedir,
  Boolean $enable_ldap_auth                 = $powerdns_admin::params::enable_ldap_auth,
  Optional[String] $ldap_bind_dn            = undef,
  Optional[String] $ldap_bind_password      = undef,
  Optional[String] $ldap_url                = undef,
  Optional[String] $ldap_bind_authoritative = undef,
  Boolean $ldap_require_group               = $powerdns_admin::params::ldap_require_group,
  Optional[String] $ldap_require_group_dn   = undef,
) inherits ::powerdns_admin::params {

  $docroot = "${basedir}/powerdns_admin"

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

  file { "${powerdns_admin::params::apache_confd}/powerdns_admin.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    content => template('powerdns_admin/apache/conf.erb'),
    require => File["${docroot}/wsgi.py"],
    notify  => Service[$powerdns_admin::params::apache_service],
  }
}
