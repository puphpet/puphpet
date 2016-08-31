####Table of Contents

1. [Overview](#overview)
2. [Module Description ](#module-description)
3. [Setup](#setup)
    * [What swap_file affects](#what-swap_file-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)

##Overview

Manage [swap files](http://en.wikipedia.org/wiki/Paging) for your Linux environments. This is based on the gist by @Yggdrasil, with a few changes and added specs.

##Setup

###What swap_file affects

* Swapfiles on the system
* Any mounts of swapfiles

##Usage

The simplest use of the module is this:

```puppet
include swap
```

By default, the module it will create a swap file under `/mnt/swap.1` with the default size taken from the `$::memorysizeinbytes` fact divided by 1000000.

For a custom setup, you can do something like this:

```puppet
swap {
  swapfile     => '/swapfile/swap1',
  swapfilesize => '1000000'
}
```

To remove a prexisting swap, you can use ensure absent:

```puppet
swap {
  ensure   => 'absent'
  swapfile => '/swapfile/swap1',
}
```

##Limitations

Primary support is for Debian and RedHat, but should work on all Linux flavours.

##Development

Follow the CONTRIBUTING guidelines! :)
