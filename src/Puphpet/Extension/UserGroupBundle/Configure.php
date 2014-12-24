<?php

namespace Puphpet\Extension\UserGroupBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Users & Groups',
        'slug'            => 'users_groups',
        'frontController' => 'puphpet.extension.user_group.front_controller',
    ];
}
