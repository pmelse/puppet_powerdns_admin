# Class: puppet_powerdns_admin
# here we provide installation and configuration of powerdnsadmin
# and a python virtualenv
#
# === module requirements:
# vcsrepo
# python
# stdlib
# === Parameters
# document parameters here.
#
# [*user*]
#   (string) powerdns_admin system user.
#   Defaults to 'powerdns_admin' ($::powerdns_admin::params::user)
#
# [*homedir*]
#   (string) powerdns_admin system user's home directory.
#   Defaults to undef, which will make the default home directory /home/$user
#
# [*group*]
#   (string) powerdns_admin system group.
#   Defaults to 'powerdns_admin' ($::powerdns_admin::params::group)
#
# [*groups*]
#   (string) The groups to which the user belongs. The primary group should
#   not be listed, and groups should be identified by name rather than by GID.
#   Multiple groups should be specified as an array.
#   Defaults to undef ($::powerdns_admin::params::groups)
#
# [*basedir*]
#   (string, absolute path) Base directory where to build powerdns_admin vcsrepo and python virtualenv.
#   Defaults to '/srv/powerdns_admin' ($::powerdns_admin::params::basedir)
#
# [*git_source*]
#   (string) Location of upstream powerdns_admin GIT repository
#   Defaults to 'https://github.com/voxpupuli/powerdns_admin' ($::powerdns_admin::params::git_source)
#
# [*manage_git*]
#   (bool) If true, require the git package. If false do nothing.
#   Defaults to false
#
# [*manage_virtualenv*]
#   (bool) If true, require the virtualenv package. If false do nothing.
#   Defaults to false
#
# [*virtualenv_version*]
#   (string) Python version to use in virtualenv.
#   Defaults to 'system'
#
# [*manage_user*]
#   (bool) If true, manage (create) this group. If false do nothing.
#   Defaults to true
#
# [*manage_group*]
#   (bool) If true, manage (create) this group. If false do nothing.
#   Defaults to true
#
class powerdns_admin (
  String $user   = $powerdns_admin::params::user,
  String $group  = $powerdns_admin::params::group,
  Stdlib::AbsolutePath $basedir  = $powendns_admin::params::basedir,
  String $git_source             = $powerdns_admin::params::git_source,
  Boolean $manage_user           = true,
  Boolean $manage_group          = true,
  Boolean $manage_git            = false,
  Boolean $manage_virtualenv     = false,
  String[1]  $virtualenv_version = $powerdns_admin::params::virtualenv_version,
  ) inherits powerdns_admin::params {

  if $manage_group {
    group { $group:
      ensure => present,
      system => true,
    }
  }

  if $manage_user {
    user { $user:
      ensure     => present,
      shell      => '/bin/bash',
      home       => $::powerdns_admin::homedir,
      managehome => true,
      gid        => $::powerdns_admin::group,
      system     => true,
      groups     => $::powernds_admin::groups,
      require    => Group[$group],
    }
  }
}
