<?php

namespace Puphpet\Extension\VagrantfileDigitalOceanBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Digital Ocean';
    protected $slug = 'vagrantfile-digital_ocean';
    protected $targetFile = 'Vagrantfile';

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
        return $this->container->get('puphpet.extension.vagrantfile.digital_ocean.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.vagrantfile.digital_ocean.manifest_controller');
    }
}
