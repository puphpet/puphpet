<?php

namespace Puphpet\Extension\HhvmBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'HHVM';
    protected $slug = 'hhvm';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'puphpet'     => ":git => 'https://github.com/puphpet/puppet-puphpet.git'",
        'puppi'       => ":git => 'https://github.com/puphpet/puppi.git'",
        'supervisord' => ":git => 'https://github.com/puphpet/puppet-supervisord.git'",
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
        return $this->container->get('puphpet.extension.hhvm.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.hhvm.manifest_controller');
    }
}
