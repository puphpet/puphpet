<?php

namespace Puphpet\Extension\VagrantfileRackspaceBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'               => 'Rackspace',
        'slug'               => 'vagrantfile-rackspace',
        'frontController'    => 'puphpet.extension.vagrantfile.rackspace.front_controller',
        'manifestController' => 'puphpet.extension.vagrantfile.rackspace.manifest_controller',
        'targetFile'         => 'Vagrantfile',
    ];
}
