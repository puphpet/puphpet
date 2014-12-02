<?php

namespace Puphpet\Extension\XdebugBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Xdebug',
        'slug'            => 'xdebug',
        'frontController' => 'puphpet.extension.xdebug.front_controller',
    ];
}
