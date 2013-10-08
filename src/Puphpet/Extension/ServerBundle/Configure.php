<?php

namespace Puphpet\Extension\ServerBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Server Basics';
    protected $slug = 'server';
    protected $targetFile = 'puppet/manifests/default.pp';

    protected $sources = [
        'stdlib' => ":git => 'git://github.com/puppetlabs/puppetlabs-stdlib.git'",
        'concat' => ":git => 'git://github.com/puppetlabs/puppetlabs-concat.git'",
        'apt'    => ":git => 'git://github.com/puphpet/puppetlabs-apt.git'",
        'git'    => ":git => 'git://github.com/nesi/puppet-git.git'",
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
        return $this->container->get('puphpet.extension.server.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.server.manifest_controller');
    }
}
