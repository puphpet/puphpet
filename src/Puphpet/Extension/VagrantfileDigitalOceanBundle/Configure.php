<?php

namespace Puphpet\Extension\VagrantfileDigitalOceanBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'               => 'Digital Ocean',
        'slug'               => 'vagrantfile-digital_ocean',
        'frontController'    => 'puphpet.extension.vagrantfile.digital_ocean.front_controller',
        'manifestController' => 'puphpet.extension.vagrantfile.digital_ocean.manifest_controller',
        'targetFile'         => 'Vagrantfile',
    ];
}
