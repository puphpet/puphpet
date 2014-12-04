<?php

namespace Puphpet\Extension\SolrBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    const DIR = __DIR__;

    protected $conf = [
        'name'            => 'Solr',
        'slug'            => 'solr',
        'frontController' => 'puphpet.extension.solr.front_controller',
    ];
}
