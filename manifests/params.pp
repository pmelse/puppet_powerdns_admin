# == Class: powerdns_admin::params
#
# Defines default values for powerdns_admin parameters.
#
# Inherited by Class['powerdns_admin'].
#
class powerdns_admin::params {
  case $facts['os']['family'] {
    'Debian': {
      $apache_confd = '/etc/apache2/conf-enabled'
      $apache_service = 'apache2'
    }

    'RedHat': {
      $apache_confd   = '/etc/httpd/conf.d'
      $apache_service = 'httpd'
      File {
        seltype => 'httpd_sys_content_t',
      }
    }
    default: {
      nofify('Operating System Not Supported')
    }
  }

  $user  = 'powerdns_admin'
  $group = 'powerdns_admin'
  $basedir = '/srv/powerdnsadmin'
  $git_source = 'https://github.com/pmelse/powerdns_admin'
  $virtualenv = 'python-virtualenv'
  $virtualenv_version = 'system'
}
