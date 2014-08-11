<?php

namespace Puphpet\Extension\PythonBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Python';
    protected $slug = 'python';
    protected $targetFile = 'puphpet/puppet/nodes/python.pp';

    protected $sources = [
        'python' => ":git => 'https://github.com/stankevich/puppet-python.git'",
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
        return $this->container->get('puphpet.extension.python.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.python.manifest_controller');
    }
}
