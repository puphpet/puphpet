<?php

namespace Puphpet\Extension\VagrantfileLocalBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'               => 'Local',
        'slug'               => 'vagrantfile-local',
        'frontController'    => 'puphpet.extension.vagrantfile.local.front_controller',
        'manifestController' => 'puphpet.extension.vagrantfile.local.manifest_controller',
        'targetFile'         => 'Vagrantfile',
    ];
}
