<?php

namespace Puphpet\Extension\HhvmBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'HHVM',
        'slug'            => 'hhvm',
        'frontController' => 'puphpet.extension.hhvm.front_controller',
    ];
}
