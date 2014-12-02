<?php

namespace Puphpet\Extension\NginxBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Nginx',
        'slug'            => 'nginx',
        'frontController' => 'puphpet.extension.nginx.front_controller',
    ];
}
