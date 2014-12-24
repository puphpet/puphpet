<?php

namespace Puphpet\Extension\PackageBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Packages',
        'slug'            => 'server',
        'frontController' => 'puphpet.extension.package.front_controller',
    ];
}
