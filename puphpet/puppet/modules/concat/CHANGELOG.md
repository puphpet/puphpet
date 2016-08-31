##2014-09-10 - Supported Release 1.1.1

###Summary

This is a bugfix release, and the first supported release of the 1.1.x series.

####Bugfixes
- Make the `$order` parameter default to a string and be validated as an integer
  or a string
- Use the ruby script on Solaris to not break Sol10 support
- Add quotes to the ryby script location for Windows
- Fix typos in README.md
- Make regex in concat::setup case-insensitive to make it work on Windows
- Make sure concat fragments are always replaced
- Fix validation to allow `$backup` to be a boolean
- Remove dependency on stdlib 4.x
- Fix for lack of idempotency with `ensure => 'absent'`
- Fix tests and spec_helper
- Synchronized files for more consistency across modules via modulesync

##2014-05-14 - Release 1.1.0

###Summary

This release is primarily a bugfix release since 1.1.0-rc1.

####Features
- Improved testing, with tests moved to beaker

####Bugfixes
- No longer attempts to set fragment owner and mode on Windows
- Fix numeric sorting
- Fix incorrect quoting
- Fix newlines

##2014-01-03 - Release 1.1.0-rc1

###Summary

This release of concat was 90% written by Joshua Hoblitt, and the module team
would like to thank him for the huge amount of work he put into this release.

This module deprecates a bunch of old parameters and usage patterns, modernizes
much of the manifest code, simplifies a whole bunch of logic and makes
improvements to almost all parts of the module.

The other major feature is windows support, courtesy of luisfdez, with an
alternative version of the concat bash script in ruby.  We've attempted to
ensure that there are no backwards incompatible changes, all users of 1.0.0
should be able to use 1.1.0 without any failures, but you may find deprecation
warnings and we'll be aggressively moving for a 2.0 to remove those too.

For further information on deprecations, please read:
https://github.com/puppetlabs/puppetlabs-concat/blob/master/README.md#api-deprecations

####Removed
- Puppet 0.24 support.
- Filebucket backup of all file resources except the target concatenated file.
- Default owner/user/group values.
- Purging of long unused /usr/local/bin/concatfragments.sh

###Features
- Windows support via a ruby version of the concat bash script.
- Huge amount of acceptance testing work added.
- Documentation (README) completely rewritten.
- New parameters in concat:
 - `ensure`: Controls if the file should be present/absent at all.
 - Remove requirement to include concat::setup in manifests.
 - Made `gnu` parameter deprecated.
 - Added parameter validation.

###Bugfixes
 - Ensure concat::setup runs before concat::fragment in all cases.
 - Pluginsync references updated for modern Puppet.
 - Fix incorrect group parameter.
 - Use $owner instead of $id to avoid confusion with $::id
 - Compatibility fixes for Puppet 2.7/ruby 1.8.7
 - Use LC_ALL=C instead of LANG=C
 - Always exec the concatfragments script as root when running as root.
 - Syntax and other cleanup changes.

##2014-06-25 - Supported Release 1.0.4
###Summary

This release has test fixes.

####Features
- Added test support for OSX.

####Bugfixes

####Known bugs

* Not supported on Windows.

##2014-06-04 - Release 1.0.3
###Summary

This release adds compatibility for PE3.3 and fixes tests.

####Features
- Added test support for Ubuntu Trusty.

####Bugfixes

####Known bugs

*Not supported on Windows.

##2014-03-04 - Supported Release 1.0.2
###Summary

This is a supported release. No functional changes were made from 1.0.1.

####Features
- Huge amount of tests backported from 1.1.
- Documentation rewrite.

####Bugfixes

####Known Bugs

* Not supported on Windows.


##2014-02-12 - 1.0.1

###Summary

Minor bugfixes for sorting of fragments and ordering of resources.

####Bugfixes
- LANG => C replaced with LC_ALL => C to reduce spurious recreation of
fragments.
- Corrected pluginsync documentation.
- Ensure concat::setup always runs before fragments.


##2013-08-09 - 1.0.0

###Summary

Many new features and bugfixes in this release, and if you're a heavy concat
user you should test carefully before upgrading.  The features should all be
backwards compatible but only light testing has been done from our side before
this release.

####Features
- New parameters in concat:
 - `replace`: specify if concat should replace existing files.
 - `ensure_newline`: controls if fragments should contain a newline at the end.
- Improved README documentation.
- Add rspec:system tests (rake spec:system to test concat)

####Bugfixes
- Gracefully handle \n in a fragment resource name.
- Adding more helpful message for 'pluginsync = true'
- Allow passing `source` and `content` directly to file resource, rather than
defining resource defaults.
- Added -r flag to read so that filenames with \ will be read correctly.
- sort always uses LANG=C.
- Allow WARNMSG to contain/start with '#'.
- Replace while-read pattern with for-do in order to support Solaris.

####CHANGELOG:
- 2010/02/19 - initial release
- 2010/03/12 - add support for 0.24.8 and newer
             - make the location of sort configurable
             - add the ability to add shell comment based warnings to
               top of files
             - add the ablity to create empty files
- 2010/04/05 - fix parsing of WARN and change code style to match rest
               of the code
             - Better and safer boolean handling for warn and force
             - Don't use hard coded paths in the shell script, set PATH
               top of the script
             - Use file{} to copy the result and make all fragments owned
               by root.  This means we can chnage the ownership/group of the
               resulting file at any time.
             - You can specify ensure => "/some/other/file" in concat::fragment
               to include the contents of a symlink into the final file.
- 2010/04/16 - Add more cleaning of the fragment name - removing / from the $name
- 2010/05/22 - Improve documentation and show the use of ensure =>
- 2010/07/14 - Add support for setting the filebucket behavior of files
- 2010/10/04 - Make the warning message configurable
- 2010/12/03 - Add flags to make concat work better on Solaris - thanks Jonathan Boyett
- 2011/02/03 - Make the shell script more portable and add a config option for root group
- 2011/06/21 - Make base dir root readable only for security
- 2011/06/23 - Set base directory using a fact instead of hardcoding it
- 2011/06/23 - Support operating as non privileged user
- 2011/06/23 - Support dash instead of bash or sh
- 2011/07/11 - Better solaris support
- 2011/12/05 - Use fully qualified variables
- 2011/12/13 - Improve Nexenta support
- 2012/04/11 - Do not use any GNU specific extensions in the shell script
- 2012/03/24 - Comply to community style guides
- 2012/05/23 - Better errors when basedir isnt set
- 2012/05/31 - Add spec tests
- 2012/07/11 - Include concat::setup in concat improving UX
- 2012/08/14 - Puppet Lint improvements
- 2012/08/30 - The target path can be different from the $name
- 2012/08/30 - More Puppet Lint cleanup
- 2012/09/04 - RELEASE 0.2.0
- 2012/12/12 - Added (file) $replace parameter to concat
