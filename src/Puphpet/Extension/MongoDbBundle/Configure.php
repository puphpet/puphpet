<?php

namespace Puphpet\Extension\MongoDbBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'MongoDB';
    protected $slug = 'mongodb';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'mongodb' => ":git => 'https://github.com/puphpet/puppetlabs-mongodb.git'",
        'apt'     => ":git => 'https://github.com/puphpet/puppetlabs-apt.git'",
        'yum'     => ":git => 'https://github.com/puphpet/puppet-yum.git'",
        'php'     => ":git => 'https://github.com/puphpet/puppet-php.git'",
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
        return $this->container->get('puphpet.extension.mongodb.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.mongodb.manifest_controller');
    }
}
