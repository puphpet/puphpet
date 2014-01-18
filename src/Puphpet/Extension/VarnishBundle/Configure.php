<?php

namespace Puphpet\Extension\VarnishBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Varnish';
    protected $slug = 'varnish';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'varnish'     => ":git => 'https://github.com/podarok/puppet-varnish.git'",
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
        return $this->container->get('puphpet.extension.varnish.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.varnish.manifest_controller');
    }
}
