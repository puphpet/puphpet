<?php

namespace Puphpet\Extension\MongoDbBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'MongoDB',
        'slug'            => 'mongodb',
        'frontController' => 'puphpet.extension.mongodb.front_controller',
    ];
}
