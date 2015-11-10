##2014-11-11 - Supported Releases 1.2.0
###Summary

This is primarily a bugfix release, but also includes documentation updates and synchronization of files with modulesync.

####Features
- Synchronized files using modulesync
- Improved documentation with a warning about old, manually installed inifile with PE3.3+

####Bugfixes
- Fix issue where single character settings were not being saved

##2014-09-30 - Supported Releases 1.1.4
###Summary

This release includes documentation and test updates.

##2014-07-15 - Supported Release 1.1.3
###Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

##2014-07-10 - Supported Release 1.1.2
###Summary

This is a re-packaging release.

##2014-07-07 - Release 1.1.1
###Summary

This supported bugfix release corrects the inifile section header detection
regex (so you can use more characters in your section titles).

####Bugfixes
- Correct section regex to allow anything other than ]
- Correct `exists?` to return a boolean
- Lots of test updates
- Add missing CONTRIBUTING.md

##2014-06-04 - Release 1.1.0
###Summary

This is a compatibility and feature release.  This release adds one new
feature, the ability to control the quote character used.  This allows you to
do things like:

```
ini_subsetting { '-Xms':
    ensure     => present,
    path       => '/some/config/file',
    section    => '',
    setting    => 'JAVA_ARGS',
    quote_char => '"',
    subsetting => '-Xms'
    value      => '256m',
  }
```

Which builds:

```
JAVA_ARGS="-Xmx256m -Xms256m"
```

####Features
- Add quote_char parameter to the ini_subsetting resource type

####Bugfixes

####Known Bugs
* No known bugs

##2014-03-04 - Supported Release 1.0.3
###Summary

This is a supported release.  It has only test changes.

####Features

####Bugfixes

####Known Bugs
* No known bugs


##2014-02-26 - Version 1.0.2
###Summary
This release adds supported platforms to metadata.json and contains spec fixes


##2014-02-12 - Version 1.0.1
###Summary
This release is a bugfix for handling whitespace/[]'s better, and adding a
bunch of tests.

####Bugfixes
- Handle whitespace in sections
- Handle square brances in values
- Add metadata.json
- Update some travis testing
- Tons of beaker-rspec tests


##2013-07-16 - Version 1.0.0
####Features
- Handle empty values.
- Handle whitespace in settings names (aka: server role = something)
- Add mechanism for allowing ini_setting subclasses to override the
formation of the namevar during .instances, to allow for ini_setting
derived types that manage flat ini-file-like files and still purge
them.

---
##2013-05-28 - Chris Price <chris@puppetlabs.com> - 0.10.3
 * Fix bug in subsetting handling for new settings (cbea5dc)

##2013-05-22 - Chris Price <chris@puppetlabs.com> - 0.10.2
 * Better handling of quotes for subsettings (1aa7e60)

##2013-05-21 - Chris Price <chris@puppetlabs.com> - 0.10.1
 * Change constants to class variables to avoid ruby warnings (6b19864)

##2013-04-10 - Erik Dalén <dalen@spotify.com> - 0.10.1
 * Style fixes (c4af8c3)

##2013-04-02 - Dan Bode <dan@puppetlabs.com> - 0.10.1
 * Add travisfile and Gemfile (c2052b3)

##2013-04-02 - Chris Price <chris@puppetlabs.com> - 0.10.1
 * Update README.markdown (ad38a08)

##2013-02-15 - Karel Brezina <karel.brezina@gmail.com> - 0.10.0
 * Added 'ini_subsetting' custom resource type (4351d8b)

##2013-03-11 - Dan Bode <dan@puppetlabs.com> - 0.10.0
 * guard against nil indentation values (5f71d7f)

##2013-01-07 - Dan Bode <dan@puppetlabs.com> - 0.10.0
 * Add purging support to ini file (2f22483)

##2013-02-05 - James Sweeny <james.sweeny@puppetlabs.com> - 0.10.0
 * Fix test to use correct key_val_parameter (b1aff63)

##2012-11-06 - Chris Price <chris@puppetlabs.com> - 0.10.0
 * Added license file w/Apache 2.0 license (5e1d203)

##2012-11-02 - Chris Price <chris@puppetlabs.com> - 0.9.0
 * Version 0.9.0 released

##2012-10-26 - Chris Price <chris@puppetlabs.com> - 0.9.0
 * Add detection for commented versions of settings (a45ab65)

##2012-10-20 - Chris Price <chris@puppetlabs.com> - 0.9.0
 * Refactor to clarify implementation of `save` (f0d443f)

##2012-10-20 - Chris Price <chris@puppetlabs.com> - 0.9.0
 * Add example for `ensure=absent` (e517148)

##2012-10-20 - Chris Price <chris@puppetlabs.com> - 0.9.0
 * Better handling of whitespace lines at ends of sections (845fa70)

##2012-10-20 - Chris Price <chris@puppetlabs.com> - 0.9.0
 * Respect indentation / spacing for existing sections and settings (c2c26de)

##2012-10-17 - Chris Price <chris@puppetlabs.com> - 0.9.0
 * Minor tweaks to handling of removing settings (cda30a6)

##2012-10-10 - Dan Bode <dan@puppetlabs.com> - 0.9.0
 * Add support for removing lines (1106d70)

##2012-10-02 - Dan Bode <dan@puppetlabs.com> - 0.9.0
 * Make value a property (cbc90d3)

##2012-10-02 - Dan Bode <dan@puppetlabs.com> - 0.9.0
 * Make ruby provider a better parent. (1564c47)

##2012-09-29 - Reid Vandewiele <reid@puppetlabs.com> - 0.9.0
 * Allow values with spaces to be parsed and set (3829e20)

##2012-09-24 - Chris Price <chris@pupppetlabs.com> - 0.0.3
 * Version 0.0.3 released

##2012-09-20 - Chris Price <chris@puppetlabs.com> - 0.0.3
 * Add validation for key_val_separator (e527908)

##2012-09-19 - Chris Price <chris@puppetlabs.com> - 0.0.3
 * Allow overriding separator string between key/val pairs (8d1fdc5)

##2012-08-20 - Chris Price <chris@pupppetlabs.com> - 0.0.2
 * Version 0.0.2 released

##2012-08-17 - Chris Price <chris@pupppetlabs.com> - 0.0.2
 * Add support for "global" section at beginning of file (c57dab4)
