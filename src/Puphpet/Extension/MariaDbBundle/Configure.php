<?php

namespace Puphpet\Extension\MariaDbBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'MariaDB';
    protected $slug = 'mariadb';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'apt'    => ":git => 'https://github.com/puphpet/puppetlabs-apt.git'",
        'mysql'  => ":git => 'https://github.com/puphpet/puppetlabs-mysql.git'",
        'stdlib' => ":git => 'https://github.com/puphpet/puppetlabs-stdlib.git'",
        'yum'    => ":git => 'https://github.com/puphpet/puppet-yum.git'",
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
        return $this->container->get('puphpet.extension.mariadb.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.mariadb.manifest_controller');
    }
}
