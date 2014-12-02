<?php

namespace Puphpet\Extension\PhpBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Php',
        'slug'            => 'php',
        'frontController' => 'puphpet.extension.php.front_controller',
    ];
}
