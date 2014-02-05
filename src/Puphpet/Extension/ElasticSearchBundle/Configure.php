<?php

namespace Puphpet\Extension\ElasticSearchBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Elastic Search';
    protected $slug = 'elastic_search';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'elasticsearch' => ":git => 'https://github.com/puphpet/puppet-elasticsearch.git'"
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
        return $this->container->get('puphpet.extension.elastic_search.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.elastic_search.manifest_controller');
    }
}
