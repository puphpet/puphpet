<?php

namespace Puphpet\Extension\ServerBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Server Basics',
        'slug'            => 'server',
        'frontController' => 'puphpet.extension.server.front_controller',
    ];
}
