# Contributing

This module has become very popular, and now powers some pretty big infrastructures on many platforms. As such, it is important to be mindful of any changes that you make. Please take a moment to read the below requirements.

## TL;DR

* All PRs must adhere to the Community Style Guide
* Specs must exist for appropriate blocks of code.

## Style Matters

In an effort to introduce consistency around the code contributed to this repository, we will be using the Puppet Labs style guide. Please take a moment and familiarize yourself with this document if you have not before. http://docs.puppetlabs.com/guides/style_guide.html

If you find yourself reading some legacy code that does not adhere to these guidelines... don't fret! There is work in progress to help normalize code amongst this new style. Do your best to adhere to the new guidelines, and if you're feeling helpful, create a new issue in this repo and highlight it. PRs for additional :+1:s

For now, these style guidelines are **HIGHLY ENCOURAGED**, and a maintainer will more than likely push back if there are deviations for new code additions. These will eventually be automatically validated, but for now please do your best. If you get stuck or frustrated, please call in help from a maintainer for assistance.

## Testing

[rspec-puppet](http://rspec-puppet.com/) specs exist for a sizable chunk of our existing functionality, but not all. See here:

https://github.com/jfryman/puppet-nginx/tree/master/spec

Writing specs to confirm behavior before and after your changes is a great way to gain confidence that you're not introducing a regression.

Pull requests with specs will be merged much more quickly than those without.

Tests should not re-create resource declarations in the `rspec` DSL. Rather, test for item that...

* Are modified by a variable
* Test control logic
* Template generation
