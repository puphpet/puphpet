<?php

namespace Puphpet\Extension\PythonBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Python',
        'slug'            => 'python',
        'frontController' => 'puphpet.extension.python.front_controller',
    ];
}
