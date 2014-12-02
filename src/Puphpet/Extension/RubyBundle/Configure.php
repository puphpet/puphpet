<?php

namespace Puphpet\Extension\RubyBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Ruby',
        'slug'            => 'ruby',
        'frontController' => 'puphpet.extension.ruby.front_controller',
    ];
}
