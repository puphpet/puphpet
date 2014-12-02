<?php

namespace Puphpet\Extension\XhprofBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Xhprof',
        'slug'            => 'xhprof',
        'frontController' => 'puphpet.extension.xhprof.front_controller',
    ];
}
