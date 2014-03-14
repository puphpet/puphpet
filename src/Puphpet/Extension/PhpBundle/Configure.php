<?php

namespace Puphpet\Extension\PhpBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Php';
    protected $slug = 'php';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
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
        return $this->container->get('puphpet.extension.php.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.php.manifest_controller');
    }
}
