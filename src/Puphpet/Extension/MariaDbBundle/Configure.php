<?php

namespace Puphpet\Extension\MariaDbBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'MariaDB',
        'slug'            => 'mariadb',
        'frontController' => 'puphpet.extension.mariadb.front_controller',
    ];
}
