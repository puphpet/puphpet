<?php

namespace Puphpet\Extension\RabbitMQBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'RabbitMQ',
        'slug'            => 'rabbitmq',
        'frontController' => 'puphpet.extension.rabbitmq.front_controller',
    ];
}
