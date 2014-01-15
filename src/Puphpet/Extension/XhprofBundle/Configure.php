<?php

namespace Puphpet\Extension\XhprofBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Xhprof';
    protected $slug = 'xhprof';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'apt'     => ":git => 'https://github.com/puphpet/puppetlabs-apt.git'",
        'vcsrepo' => ":git => 'https://github.com/puphpet/puppetlabs-vcsrepo.git'",
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
        return $this->container->get('puphpet.extension.xhprof.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.xhprof.manifest_controller');
    }
}
