<?php

namespace Puphpet\Extension\VagrantfileSoftlayerBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'               => 'Softlayer',
        'slug'               => 'vagrantfile-softlayer',
        'frontController'    => 'puphpet.extension.vagrantfile.softlayer.front_controller',
        'manifestController' => 'puphpet.extension.vagrantfile.softlayer.manifest_controller',
        'targetFile'         => 'Vagrantfile',
    ];
}
