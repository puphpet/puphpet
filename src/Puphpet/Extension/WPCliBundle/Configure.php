<?php

namespace Puphpet\Extension\WPCliBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'WP-Cli';
    protected $slug = 'wpcli';
    protected $targetFile = 'puphpet/puppet/nodes/wpcli.pp';

    protected $sources = [
        'wpcli'    => ":git => 'https://github.com/puphpet/puppet-wpcli.git'",
        'php'      => ":git => 'https://github.com/puphpet/puppet-php.git'",
        'composer' => ":git => 'https://github.com/puphpet/puppet-composer.git'",
        'puphpet'  => ":git => 'https://github.com/puphpet/puppet-puphpet.git'",
        'puppi'    => ":git => 'https://github.com/puphpet/puppi.git'",
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
        return $this->container->get('puphpet.extension.wpcli.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.wpcli.manifest_controller');
    }
}
