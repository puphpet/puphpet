<?php

namespace Puphpet\Extension\ApcBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'APC';
    protected $slug = 'apc';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [];

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
        return $this->container->get('puphpet.extension.apc.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.apc.manifest_controller');
    }
}
