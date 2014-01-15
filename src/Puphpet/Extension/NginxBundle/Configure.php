<?php

namespace Puphpet\Extension\NginxBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Nginx';
    protected $slug = 'nginx';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'nginx' => ":git => 'https://github.com/puphpet/puppet-nginx.git'",
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
        return $this->container->get('puphpet.extension.nginx.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.nginx.manifest_controller');
    }
}
