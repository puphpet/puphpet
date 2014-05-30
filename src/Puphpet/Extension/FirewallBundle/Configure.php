<?php

namespace Puphpet\Extension\FirewallBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Firewall';
    protected $slug = 'firewall';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'stdlib'   => ":git => 'https://github.com/puphpet/puppetlabs-stdlib.git'",
        'firewall' => ":git => 'https://github.com/puppetlabs/puppetlabs-firewall.git'",
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
        return $this->container->get('puphpet.extension.firewall.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.firewall.manifest_controller');
    }
}
