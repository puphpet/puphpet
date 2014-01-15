<?php

namespace Puphpet\Extension\BeanstalkdBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Beanstalkd';
    protected $slug = 'beanstalkd';
    protected $targetFile = 'puphpet/puppet/manifest.pp';

    protected $sources = [
        'beanstalkd' => ":git => 'https://github.com/puphpet/puppet-beanstalkd.git'",
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
        return $this->container->get('puphpet.extension.beanstalkd.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.beanstalkd.manifest_controller');
    }
}
