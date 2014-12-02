<?php

namespace Puphpet\Extension\WPCliBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'WP-Cli',
        'slug'            => 'wpcli',
        'frontController' => 'puphpet.extension.wpcli.front_controller',
    ];
}
