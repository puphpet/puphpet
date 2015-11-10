# pyenv

[Pyenv](https://github.com/yyuu/pyenv) provides a way to build and use
Pythons outside of your platforms package manager's purview.

#### Table of contents

1. [Overview - What is the pyenv module?](#overview)
2. [Module description - What is the purpose of this mdoule?](#module-description)
3. [Setup - The basics of getting started with pyenv](#setup)
    * [Beginning with pyenv - Installation](#beginning-with-pyenv)
    * [Installing a Python - Basic options for getting started](#installing-a-python)
    * [Relocating pyenv](#relocating-the-pyenv-installation)
4. [Usage - The classes and types available for configuration](#usage)
    * [Classes](#classes)
        * [Class: pyenv](#class-pyenv)
    * [Types](#types)
        * [Type: pyenv_python](#type-pyenv_python)

## Overview
The pyenv module allows you to install pyenv on a target system. The module
also provides a Puppet type called `pyenv_python` which will instruct pyenv
to build a Python for you.

This module only supports global installations of pyenv, meaning it will not
install into a user's home directory. Though it can be made to do so the types
that come with it do not support this work flow.

## Module description
Python is a often-used programming language ranging from simple scripts to
automate a repetitive task to powering large (web) applications. The problem we
often encounter is that a distribution only ships with one (outdated) Python
version. Pyenv remedies this situation by allow you to build your own Pythons
and use those instead.

## Setup
This modules will:

* Install pyenv for you. It will do so by checking out the latest tag at the
  time this module was written;
* Symlink pyenv so that it will be found when looking through `$PATH`;
* Install the necessary packages to ensure you can build Python;
* A type and provider to make Puppet build Pythons through pyenv.

This module requires:

* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [puppetlabs/vcsrepo](https://forge.puppetlabs.com/puppetlabs/vcsrepo)

### Beginning with pyenv
In order to install pyenv with the defaults:

```puppet
include ::pyenv
```

This will install pyenv for you in `/usr/local/pyenv` and symlink
`/usr/local/bin/pyenv` to `/usr/local/pyenv/bin/pyenv`.

### Installing a Python
Use the `pyenv_python` type to instruct Puppet to build a Python:

```puppet
pyenv_python { '3.4.0': }
```

The `pyenv_python` defaults to `ensure => present,`, therefor you do not need to
specify it yourself.

If you want to build a debug version of a Python add *-debug* to the name of
the Python:

```puppet
pyenv_python { '3.4.0-debug': }
```

### Relocation the pyenv installation
The module installs pyenv to `/usr/local/pyenv` by default and symlinks the
`pyenv` binary onto your path. This is needed so that the provider can find
`pyenv` and set up the `PYENV_ROOT` environment variable accordingly.

If you change the location of the pyenv checkout you must either:

* Make sure the symlink is changed too. This is done automatically if you
 set `symlink_pyenv` to true;
* Create a custom Fact called `pyenv_binary` with the location of
 `/path/to/checkout/bin/pyenv`.

The former of the two methods is preferred if at all possible.

If Puppet's `$PATH` does not by default include `/usr/local/bin` either add
that to it or change the `symlink_path` to a different location that is part of
Puppet's `$PATH`.

## Usage

### Classes and defined types

#### Class: `pyenv`
The pyenv module's primary and only class, `pyenv` sets up your system with pyenv
and the necessary packages to compile.

It takes the following parameters:

* `ensure_repo`: Whether to add or remove the repository
    * default: `present`
    * options: `present`, `absent`
* `repo_location`: Where to checkout the repository on the filesystem
    * default: `/usr/local/pyenv`
    * options: any absolute path
* `repo_revision`: The revision to checkout
    * default: `v0.4.0-20140404`
    * options: tag, commit SHA, branch
* `symlink_pyenv`: Create a symlink to the pyenv binary
    * default: `true`
    * options: `true`, `false`
* `symlink_path`: Where to symlink pyenv to
    * default: `/usr/local/bin`
    * options: any absolute path known to `$PATH`
* `manage_packages`: Install packages needed to compile Python
    * default: `true`
    * options: `true`, `false`
* `ensure_packages`: State of the packages to ensure
    * default: `latest`
    * options: any valid value for the ensure attribute of the package type
* `python_build_packages`: Array/list of packages to install
    * default: depends on what Facter returns for `osfamily`, see
      (params.pp)[params.pp]
    * options: an array of strings representing package names

### Types

#### Type: `pyenv_python`

`pyenv_python` allows you to build a Python which in turn will make it
available to someone wishing to use it.

It takes the following options:

* `name` (namevar): name of the Python to be installed, see `pyenv install -l`.
  If omitted the title of the resource will be used.
* `ensure`: state the Python should be in
    * default: `present`
    * options: valid values for ensure
* `keep`: keep the sources after compiling
    * default: `false`
    * options: `true`, `false`
* `virtualenv`: Install virtualenv in the new Python
    * default: `false`
    * options: `true`, `false`

Keep one thing in mind: if a Python was installed **without** setting `keep` to
`true` you cannot add it later, the provider will call the `fail()` method in
such cases.
