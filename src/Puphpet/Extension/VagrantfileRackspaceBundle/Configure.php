<?php

namespace Puphpet\Extension\VagrantfileRackspaceBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Rackspace';
    protected $slug = 'vagrantfile-rackspace';
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
        return $this->container->get('puphpet.extension.vagrantfile.rackspace.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.vagrantfile.rackspace.manifest_controller');
    }
}
