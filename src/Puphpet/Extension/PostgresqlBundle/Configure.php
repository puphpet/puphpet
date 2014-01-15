<?php

namespace Puphpet\Extension\PostgresqlBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'PostgreSQL';
    protected $slug = 'postgresql';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'postgresql' => ":git => 'https://github.com/puphpet/puppetlabs-postgresql.git'",
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
        return $this->container->get('puphpet.extension.postgresql.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.postgresql.manifest_controller');
    }
}
