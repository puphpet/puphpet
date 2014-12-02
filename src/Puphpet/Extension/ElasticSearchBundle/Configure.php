<?php

namespace Puphpet\Extension\ElasticSearchBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Elastic Search',
        'slug'            => 'elastic_search',
        'frontController' => 'puphpet.extension.elastic_search.front_controller',
    ];
}
