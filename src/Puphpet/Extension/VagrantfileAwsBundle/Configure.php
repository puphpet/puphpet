<?php

namespace Puphpet\Extension\VagrantfileAwsBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'               => 'Amazon Web Services',
        'slug'               => 'vagrantfile-aws',
        'frontController'    => 'puphpet.extension.vagrantfile.aws.front_controller',
        'manifestController' => 'puphpet.extension.vagrantfile.aws.manifest_controller',
        'targetFile'         => 'Vagrantfile',
    ];
}
