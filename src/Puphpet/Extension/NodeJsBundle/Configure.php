<?php

namespace Puphpet\Extension\NodeJsBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'NodeJs';
    protected $slug = 'nodejs';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'nodejs' => ":git => 'https://github.com/puppetlabs/puppetlabs-nodejs.git'",
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
        return $this->container->get('puphpet.extension.nodejs.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.nodejs.manifest_controller');
    }
}
