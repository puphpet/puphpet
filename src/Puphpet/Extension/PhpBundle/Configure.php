<?php

namespace Puphpet\Extension\PhpBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Php';
    protected $slug = 'php';
    protected $targetFile = 'puppet/manifests/default.pp';

    protected $sources = [
        'php'      => ":git => 'git://github.com/puphpet/puppet-php.git'",
        'composer' => ":git => 'git://github.com/puphpet/puppet-composer.git'",
        'puphpet'  => ":git => 'git://github.com/puphpet/puppet-puphpet.git'",
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
