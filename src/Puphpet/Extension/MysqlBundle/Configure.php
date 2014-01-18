<?php

namespace Puphpet\Extension\MysqlBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'MySQL';
    protected $slug = 'mysql';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'mysql' => ":git => 'https://github.com/puphpet/puppetlabs-mysql.git'",
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
        return $this->container->get('puphpet.extension.mysql.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.mysql.manifest_controller');
    }
}
