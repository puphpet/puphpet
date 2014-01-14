<?php

namespace Puphpet\Extension\ElasticsearchBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Elasticsearch';
    protected $slug = 'elasticsearch';
    protected $targetFile = 'puphpet/puppet/manifests/default.pp';

    protected $sources = [
        'elasticsearch' => ":git => 'https://github.com/elasticsearch/puppet-elasticsearch'"
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
        return $this->container->get('puphpet.extension.elasticsearch.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.elasticsearch.manifest_controller');
    }
}
