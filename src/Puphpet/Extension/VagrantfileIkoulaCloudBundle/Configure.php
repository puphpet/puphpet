<?php

namespace Puphpet\Extension\VagrantfileIkoulaCloudBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'               => 'Ikoula Cloud Hosting Services',
        'slug'               => 'vagrantfile-ikoulacloud',
        'frontController'    => 'puphpet.extension.vagrantfile.ikoulacloud.front_controller',
        'manifestController' => 'puphpet.extension.vagrantfile.ikoulacloud.manifest_controller',
        'targetFile'         => 'Vagrantfile',
    ];

}
