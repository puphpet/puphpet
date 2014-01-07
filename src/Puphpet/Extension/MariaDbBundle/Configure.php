<?php

namespace Puphpet\Extension\MariaDbBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'MariaDB';
    protected $slug = 'mariadb';
    protected $targetFile = 'puppet/manifests/default.pp';

    protected $sources = [
        'apt'    => ":git => 'git://github.com/puphpet/puppetlabs-apt.git'",
        'mysql'  => ":git => 'git://github.com/puphpet/puppetlabs-mysql.git'",
        'stdlib' => ":git => 'git://github.com/puphpet/puppetlabs-stdlib.git'",
        'yum'    => ":git => 'git://github.com/puphpet/puppet-yum.git'",
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
