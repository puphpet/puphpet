<?php

namespace Puphpet\Extension\CronBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Cron',
        'slug'            => 'cron',
        'frontController' => 'puphpet.extension.cron.front_controller',
    ];
}
