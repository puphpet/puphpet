<?php

namespace Puphpet\Extension\MysqlBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'MySQL',
        'slug'            => 'mysql',
        'frontController' => 'puphpet.extension.mysql.front_controller',
    ];
}
