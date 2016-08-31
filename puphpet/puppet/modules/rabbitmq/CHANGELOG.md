## 2015-04-28 - Version 5.2.0
###Summary
This release adds several new features for expanded configuration, support for SSL Ciphers, several bugfixes, and improved tests.

####Features
- New parameters to class `rabbitmq`
  - `ssl_ciphers`
- New parameters to class `rabbitmq::config`
  - `interface`
  - `ssl_interface`
- New parameters to type `rabbitmq_exchange`
  - `internal`
  - `auto_delete`
  - `durable`
- Adds syncing with Modulesync
- Adds support for SSL Ciphers
- Adds `file_limit` support for RedHat platforms

####Bugfixes
- Will not create `rabbitmqadmin.conf` if admin is disabled
- Fixes `check_password`
- Fix to allow bindings and queues to be created when non-default management port is being used by rabbitmq. (MODULES-1856)
- `rabbitmq_policy` converts known parameters to integers
- Updates apt key for full fingerprint compliance.
- Adds a missing `routing_key` param to rabbitmqadmin absent binding call.

## 2015-03-10 - Version 5.1.0
###Summary
This release adds several features for greater flexibility in configuration of rabbitmq, includes a number of bug fixes, and bumps the minimum required version of puppetlabs-stdlib to 3.0.0.

####Changes to defaults
- The default environment variables in `rabbitmq::config` have been renamed from `RABBITMQ_NODE_PORT` and `RABBITMQ_NODE_IP_ADDRESS` to `NODE_PORT` and `NODE_IP_ADDRESS` (MODULES-1673)

####Features
- New parameters to class `rabbitmq`
  - `file_limit`
  - `interface`
  - `ldap_other_bind`
  - `ldap_config_variables`
  - `ssl_interface`
  - `ssl_versions`
  - `rabbitmq_group`
  - `rabbitmq_home`
  - `rabbitmq_user`
- Add `rabbitmq_queue` and `rabbitmq_binding` types
- Update the providers to be able to retry commands

####Bugfixes
- Cleans up the formatting for rabbitmq.conf for readability
- Update tag splitting in the `rabbitmqctl` provider for `rabbitmq_user` to work with comma or space separated tags
- Do not enforce the source value for the yum provider (MODULES-1631)
- Fix conditional around `$pin`
- Remove broken SSL option in rabbitmqadmin.conf (MODULES-1691)
- Fix issues in `rabbitmq_user` with admin and no tags
- Fix issues in `rabbitmq_user` with tags not being sorted
- Fix broken check for existing exchanges in `rabbitmq_exchange`

## 2014-12-22 - Version 5.0.0
### Summary

This release fixes a longstanding security issue where the rabbitmq
erlang cookie was exposed as a fact by managing the cookie with a
provider. It also drops support for Puppet 2.7, adds many features
and fixes several bugs.

#### Backwards-incompatible Changes

- Removed the rabbitmq_erlang_cookie fact and replaced the logic to
  manage that cookie with a provider.
- Dropped official support for Puppet 2.7 (EOL 9/30/2014
  https://groups.google.com/forum/#!topic/puppet-users/QLguMcLraLE )
- Changed the default value of $rabbitmq::params::ldap_user_dn_pattern
  to not contain a variable
- Removed deprecated parameters: $rabbitmq::cluster_disk_nodes,
  $rabbitmq::server::manage_service, and
  $rabbitmq::server::config_mirrored_queues

#### Features

- Add tcp_keepalive parameter to enable TCP keepalive
- Use https to download rabbitmqadmin tool when $rabbitmq::ssl is true
- Add key_content parameter for offline Debian package installations
- Use 16 character apt key to avoid potential collisions
- Add rabbitmq_policy type, including support for rabbitmq <3.2.0
- Add rabbitmq::ensure_repo parameter
- Add ability to change rabbitmq_user password
- Allow disk as a valid cluster node type

#### Bugfixes

- Avoid attempting to install rabbitmqadmin via a proxy (since it is
  downloaded from localhost)
- Optimize check for RHEL GPG key
- Configure ssl_listener in stomp only if using ssl
- Use rpm as default package provider for RedHat, bringing the module in
  line with the documented instructions to manage erlang separately and allowing
  the default version and source parameters to become meaningful
- Configure cacertfile only if verify_none is not set
- Use -q flag for rabbitmqctl commands to avoid parsing inconsistent
  debug output
- Use the -m flag for rabbitmqplugins commands, again to avoid parsing
  inconsistent debug output
- Strip backslashes from the rabbitmqctl output to avoid parsing issues
- Fix limitation where version parameter was ignored
- Add /etc/rabbitmq/rabbitmqadmin.conf to fix rabbitmqadmin port usage
  when ssl is on
- Fix linter errors and warnings
- Add, update, and fix tests
- Update docs

## 2014-08-20 - Version 4.1.0
### Summary

This release adds several new features, fixes bugs, and improves tests and
documentation.

#### Features
- Autorequire the rabbitmq-server service in the rabbitmq_vhost type
- Add credentials to rabbitmqadmin URL
- Added $ssl_only parameter to rabbitmq, rabbitmq::params, and
rabbitmq::config
- Added property tags to rabbitmq_user provider

#### Bugfixes
- Fix erroneous commas in rabbitmq::config
- Use correct ensure value for the rabbitmq_stomp rabbitmq_plugin
- Set HOME env variable to nil when leveraging rabbitmq to remove type error
from Python script
- Fix location for rabbitmq-plugins for RHEL
- Remove validation for package_source to allow it to be set to false
- Allow LDAP auth configuration without configuring stomp
- Added missing $ssl_verify and $ssl_fail_if_no_peer_cert to rabbitmq::config

## 2014-05-16 - Version 4.0.0
### Summary

This release includes many new features and bug fixes.  With the exception of
erlang management this should be backwards compatible with 3.1.0.

#### Backwards-incompatible Changes
- erlang_manage was removed.  You will need to manage erlang separately. See
the README for more information on how to configure this.

#### Features
- Improved SSL support
- Add LDAP support
- Add ability to manage RabbitMQ repositories
- Add ability to manage Erlang kernel configuration options
- Improved handling of user tags
- Use nanliu-staging module instead of hardcoded 'curl'
- Switch to yum or zypper provider instead of rpm
- Add ability to manage STOMP plugin installation.
- Allow empty permission fields
- Convert existing system tests to beaker acceptance tests.

#### Bugfixes
- exchanges no longer recreated on each puppet run if non-default vhost is used
- Allow port to be UNSET
- Re-added rabbitmq::server class
- Deprecated previously unused manage_service variable in favor of 
  service_manage
- Use correct key for rabbitmq apt::source
- config_mirrored_queues variable removed
  - It previously did nothing, will now at least throw a warning if you try to
    use it
- Remove unnecessary dependency on Class['rabbitmq::repo::rhel'] in
  rabbitmq::install


## 2013-09-14 - Version 3.1.0
### Summary

This release focuses on a few small (but critical) bugfixes as well as extends
the amount of custom RabbitMQ configuration you can do with the module.

#### Features
- You can now change RabbitMQ 'Config Variables' via the parameter `config_variables`.
- You can now change RabbitMQ 'Environment Variables' via the parameter `environment_variables`.
- ArchLinux support added.

#### Fixes
- Make use of the user/password parameters in rabbitmq_exchange{}
- Correct the read/write parameter order on set_permissions/list_permissions as
  they were reversed.
- Make the module pull down 3.1.5 by default.

## 2013-07-18 3.0.0
### Summary

This release heavily refactors the RabbitMQ and changes functionality in
several key ways.  Please pay attention to the new README.md file for
details of how to interact with the class now.  Puppet 3 and RHEL are
now fully supported.  The default version of RabbitMQ has changed to
a 3.x release.

#### Bugfixes

- Improve travis testing options.
- Stop reimporting the GPG key on every run on RHEL and Debian.
- Fix documentation to make it clear you don't have to set provider => each time.
- Reference the standard rabbitmq port in the documentation instead of a custom port.
- Fixes to the README formatting.

#### Features
- Refactor the module to fix RHEL support.  All interaction with the module
is now done through the main rabbitmq class.
- Add support for mirrored queues (Only on Debian family distributions currently)
- Add rabbitmq_exchange provider (using rabbitmqadmin)
- Add new `rabbitmq` class parameters:
  - `manage_service`: Boolean to choose if Puppet should manage the service. (For pacemaker/HA setups)
- Add SuSE support.

#### Incompatible Changes

- Rabbitmq::server has been removed and is now rabbitmq::config.  You should
not use this class directly, only via the main rabbitmq class.

## 2013-04-11 2.1.0

- remove puppetversion from rabbitmq.config template
- add cluster support
- escape resource names in regexp

## 2012-07-31 Jeff McCune <jeff@puppetlabs.com> 2.0.2
- Re-release 2.0.1 with $EDITOR droppings cleaned up

## 2012-05-03 2.0.0
- added support for new-style admin users
- added support for rabbitmq 2.7.1

## 2011-06-14 Dan Bode <dan@Puppetlabs.com> 2.0.0rc1
- Massive refactor:
- added native types for user/vhost/user_permissions
- added apt support for vendor packages
- added smoke tests

## 2011-04-08 Jeff McCune <jeff@puppetlabs.com> 1.0.4
- Update module for RabbitMQ 2.4.1 and rabbitmq-plugin-stomp package.

## 2011-03-24 1.0.3
- Initial release to the forge.  Reviewed by Cody.  Whitespace is good.

## 2011-03-22 1.0.2
- Whitespace only fix again...  ack '\t' is my friend...

## 2011-03-22 1.0.1
- Whitespace only fix.

## 2011-03-22 1.0.0
- Initial Release.  Manage the package, file and service.
