<?php

namespace Puphpet\Extension\VagrantfileLocalBundle;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Local';
    protected $slug = 'vagrantfile-local';
    protected $targetFile = 'Vagrantfile';

    /**
     * @param Container $container
     */
    public function __construct(Container $container)
    {
        $this->dataLocation = __DIR__ . '/Resources/config';

        parent::__construct($container);
    }

    /**
     * @return Extension\ControllerInterface
     */
    public function getFrontController()
    {
        return $this->container->get('puphpet.extension.vagrantfile.local.front_controller');
    }

    /**
     * @return Extension\ControllerInterface
     */
    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.vagrantfile.local.manifest_controller');
    }
}
