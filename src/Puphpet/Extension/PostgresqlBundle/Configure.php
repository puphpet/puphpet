<?php

namespace Puphpet\Extension\PostgresqlBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'PostgreSQL',
        'slug'            => 'postgresql',
        'frontController' => 'puphpet.extension.postgresql.front_controller',
    ];
}
