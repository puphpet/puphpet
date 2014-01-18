<?php

namespace Puphpet\Extension\ApacheBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Apache';
    protected $slug = 'apache';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'apache' => ":git => 'https://github.com/puphpet/puppetlabs-apache.git'",
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
        return $this->container->get('puphpet.extension.apache.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.apache.manifest_controller');
    }
}
