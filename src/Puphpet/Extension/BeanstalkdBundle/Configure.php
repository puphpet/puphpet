<?php

namespace Puphpet\Extension\BeanstalkdBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Beanstalkd',
        'slug'            => 'beanstalkd',
        'frontController' => 'puphpet.extension.beanstalkd.front_controller',
    ];
}
