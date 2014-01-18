<?php

namespace Puphpet\Extension\SolrBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Solr';
    protected $slug = 'solr';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'solr' => ":git => 'https://github.com/vamsee/puppet-solr.git', :ref => '0.0.5'",
    ];

    /**
     * @param Container $container
     */
    public function __construct(Container $container)
    {
        $this->dataLocation = __DIR__ . '/Resources/config';

        parent::__construct($container);
    }

    public function getFrontController()
    {
        return $this->container->get('puphpet.extension.solr.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.solr.manifest_controller');
    }
}
