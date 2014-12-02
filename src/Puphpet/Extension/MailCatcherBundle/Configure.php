<?php

namespace Puphpet\Extension\MailCatcherBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'MailCatcher',
        'slug'            => 'mailcatcher',
        'frontController' => 'puphpet.extension.mailcatcher.front_controller',
    ];
}
