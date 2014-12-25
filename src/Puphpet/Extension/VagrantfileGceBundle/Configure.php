<?php

namespace Puphpet\Extension\VagrantfileGceBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'               => 'Google Compute',
        'slug'               => 'vagrantfile-gce',
        'frontController'    => 'puphpet.extension.vagrantfile.gce.front_controller',
        'manifestController' => 'puphpet.extension.vagrantfile.gce.manifest_controller',
        'targetFile'         => 'Vagrantfile',
    ];
}
