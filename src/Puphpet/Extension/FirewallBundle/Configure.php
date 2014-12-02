<?php

namespace Puphpet\Extension\FirewallBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Firewall',
        'slug'            => 'firewall',
        'frontController' => 'puphpet.extension.firewall.front_controller',
    ];
}
