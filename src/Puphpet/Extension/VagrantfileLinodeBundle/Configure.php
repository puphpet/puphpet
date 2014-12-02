<?php

namespace Puphpet\Extension\VagrantfileLinodeBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'               => 'Linode',
        'slug'               => 'vagrantfile-linode',
        'frontController'    => 'puphpet.extension.vagrantfile.linode.front_controller',
        'manifestController' => 'puphpet.extension.vagrantfile.linode.manifest_controller',
        'targetFile'         => 'Vagrantfile',
    ];
}
