<?php

namespace Puphpet\Extension\DrushBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Drush',
        'slug'            => 'drush',
        'frontController' => 'puphpet.extension.drush.front_controller',
    ];
}
