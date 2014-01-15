<?php

namespace Puphpet\Extension\XdebugBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Xdebug';
    protected $slug = 'xdebug';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

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
        return $this->container->get('puphpet.extension.xdebug.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.xdebug.manifest_controller');
    }
}
