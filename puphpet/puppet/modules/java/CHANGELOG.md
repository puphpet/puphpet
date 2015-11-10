##2015-01-20 - Supported Release 1.3.0
###Summary
This release adds 3 new facts for determining Java version, adds RHEL alternatives support, adds utopic support, and fixes the flag for `update-java-alternatives` when installed from a headless pacakge.

####Features
- Added RHEL support for alternatives
- New facts
  - java_major_version
  - java_patch_level
  - java_version
- Add support for utopic

####Bugfixes
- Use `--jre-headless` in the `update-java-alternatives` command when installed from a `headless` package

##2014-11-11 - Supported Version 1.2.0

###Summary: 
This release adds SLES 12 support and is tested for Future Parser Support

####Bugfixes:
- Several readme updates
- Testcase flexability increased

####Features:
- Add SLES 12 support
- Future Parser tested
- Validated against PE 3.7  

##2014-08-25 - Supported Version 1.1.2

###Summary: 
This release begins the support coverage of the puppetlabs-java module.

###Bugfixes:
- Update java alternative values from deprecated names
- Readme updated
- Testing updated

##2014-05-02 - Version 1.1.1

###Summary:

Add support for new versions of Debian and Ubuntu!

####Features:
- Add support for Ubuntu Trusty (14.04)
- Add support for Debian Jessie (8.x)

##2014-01-06 - Version 1.1.0

####Summary:

Primarily a release for Ubuntu users!

####Features:
- Add support for Ubuntu Saucy (13.10)
- Add `java_home` parameter for centralized setting of JAVA_HOME.
- Add Scientific Linux

###Bugfixes:
- Plus signs are valid in debian/ubuntu package names.

##2013-08-01 - Version 1.0.1

Matthaus Owens <matthaus@puppetlabs.com>
* Update java packages for Fedora systems

##2013-07-29 - Version 1.0.0

####Detailed Changes

Krzysztof Suszyński <krzysztof.suszynski@coi.gov.pl>
* Adding support for Oracle Enterprise Linux

Peter Drake <pdrake@allplayers.com>
* Add support for natty

Robert Munteanu <rmuntean@adobe.com>
* Add support for OpenSUSE

Martin Jackson <martin@uncommonsense-uk.com>
* Added support Amazon Linux using facter >= 1.7.x

Gareth Rushgrove <gareth@morethanseven.net>
Brett Porter <brett@apache.org>
* Fixes for older versions of CentOS
* Improvements to module build and tests

Nathan R Valentine <nrvale0@gmail.com>
* Add support for Ubuntu quantal and raring

Sharif Nassar <sharif@mediatemple.net>
* Add support for Debian alternatives, and more than one JDK/JRE per platform.

##2013-04-04 - Version 0.3.0
Reid Vandewiele <reid@puppetlabs.com> -
* Refactor, introduce params pattern

##2012-11-15 - Version 0.2.0
Scott Schneider <sschneider@puppetlabs.com>
* Add Solaris support

##2011-06-16 - Version 0.1.5
Jeff McCune <jeff@puppetlabs.com> 
* Add Debian based distro (Lucid) support

##2011-06-02 - Version 0.1.4
Jeff McCune <jeff@puppetlabs.com> 
* Fix class composition ordering problems

##2011-05-28 - Version 0.1.3
Jeff McCune <jeff@puppetlabs.com>
* Remove stages

##2011-05-26 - Version 0.1.2
Jeff McCune <jeff@puppetlabs.com>
* Changes JRE/JDK selection class parameter to $distribution

##2011-05-25 - Version 0.1.1
Jeff McCune <jeff@puppetlabs.com>
* Re-did versioning to follow semantic versioning
* Add validation of class parameters

##2011-05-24 - Version 0.1.0
Jeff McCune <jeff@puppetlabs.com> 
* Default to JDK version 6u25

##2011-05-24 - Version 0.0.1
Jeff McCune <jeff@puppetlabs.com> 
* Initial release
