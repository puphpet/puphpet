<?php

namespace Puphpet\Extension\JenkinsBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Jenkins',
        'slug'            => 'jenkins',
        'frontController' => 'puphpet.extension.jenkins.front_controller',
    ];
}
