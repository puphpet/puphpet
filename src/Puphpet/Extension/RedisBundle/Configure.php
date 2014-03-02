<?php

namespace Puphpet\Extension\RedisBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Redis';
    protected $slug = 'redis';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'redis' => ":git => 'https://github.com/puphpet/puppet-redis.git'",
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
        return $this->container->get('puphpet.extension.redis.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.redis.manifest_controller');
    }
}
