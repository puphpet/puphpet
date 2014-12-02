<?php

namespace Puphpet\Extension\SqliteBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'SQLite',
        'slug'            => 'sqlite',
        'frontController' => 'puphpet.extension.sqlite.front_controller',
    ];
}
