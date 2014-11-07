<?php

namespace Puphpet\Extension\SolrBundle;

use Puphpet\MainBundle\Extension;
use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Solr';
    protected $slug = 'solr';
    protected $targetFile = 'puphpet/puppet/nodes/solr.pp';

    protected $sources = [
        'apt'     => ":git => 'https://github.com/puphpet/puppetlabs-apt.git'",
        'vcsrepo' => ":git => 'https://github.com/puphpet/puppetlabs-vcsrepo.git'",
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
