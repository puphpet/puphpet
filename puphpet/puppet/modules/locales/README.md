# puppet-locales

Manage locales via Puppet

## Usage

By default, en and de locales will be generated.

```
  class { 'locales': }
```

Configure a bunch of locales.

```
  class { 'locales': 
    locales   => ['en_US.UTF-8 UTF-8', 'fr_CH.UTF-8 UTF-8'],
  }
```

Advanced usage allows you to select which locales will be configured as well as the default one.


```
  class { 'locales':
    default_locale  => 'en_US.UTF-8',
    locales         => ['en_US.UTF-8 UTF-8', 'fr_CH.UTF-8 UTF-8'],
  }
```

You can also set specific locale environment variables. See the locale man-page
for available LC_* environment variables and their descriptions:

```
  class { 'locales':
    default_locale  => 'en_US.UTF-8',
    locales         => ['en_US.UTF-8 UTF-8', 'fr_CH.UTF-8 UTF-8', 'en_DK.UTF-8 UTF-8', 'de_DE.UTF-8 UTF-8' ],
    lc_time         => 'en_DK.UTF-8',
    lc_paper        => 'de_DE.UTF-8',
  }
```

## Other class parameters
* locales: Name of locales to generate, default: ['en_US.UTF-8 UTF-8', 'de_DE.UTF-8 UTF-8']
* ensure: present or absent, default: present
* default_locale: string, default: 'C'. Set the default locale.
* lc_ctype: string, default: undef. Character classification and case conversion.
* lc_collate: string, default: undef. Collation order.
* lc_time: string, default: undef. Date and time formats.
* ...
* autoupgrade: true or false, default: false. Auto-upgrade package, if there is a newer version.
* package: string, default: OS specific. Set package name, if platform is not supported.
* config_file: string, default: OS specific. Set config_file, if platform is not supported.
* locale_gen_command: string, default: OS specific. Set locale_gen_command, if platform is not supported.
