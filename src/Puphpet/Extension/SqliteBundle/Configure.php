<?php

namespace Puphpet\Extension\SqliteBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'SQLite';
    protected $slug = 'sqlite';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'sqlite' => ":git => 'https://github.com/puppetlabs/puppetlabs-sqlite.git'",
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
        return $this->container->get('puphpet.extension.sqlite.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.sqlite.manifest_controller');
    }
}
