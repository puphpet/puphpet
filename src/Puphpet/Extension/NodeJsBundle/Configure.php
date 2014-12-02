<?php

namespace Puphpet\Extension\NodeJsBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'NodeJs',
        'slug'            => 'nodejs',
        'frontController' => 'puphpet.extension.nodejs.front_controller',
    ];
}
