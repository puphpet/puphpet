<?php

namespace Puphpet\Extension\RedisBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Redis',
        'slug'            => 'redis',
        'frontController' => 'puphpet.extension.redis.front_controller',
    ];
}
