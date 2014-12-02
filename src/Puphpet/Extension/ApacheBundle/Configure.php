<?php

namespace Puphpet\Extension\ApacheBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Apache',
        'slug'            => 'apache',
        'frontController' => 'puphpet.extension.apache.front_controller',
    ];
}
