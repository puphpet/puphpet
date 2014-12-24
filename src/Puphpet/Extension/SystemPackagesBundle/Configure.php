<?php

namespace Puphpet\Extension\SystemPackagesBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'System Packages',
        'slug'            => 'system-packages',
        'frontController' => 'puphpet.extension.system_packages.front_controller',
    ];
}
