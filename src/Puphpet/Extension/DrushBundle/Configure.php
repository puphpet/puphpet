<?php

namespace Puphpet\Extension\DrushBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Drush';
    protected $slug = 'drush';
    protected $targetFile = 'puppet/manifests/default.pp';

    protected $sources = [
        'drush'      => ":git => 'git://git.drupal.org/project/puppet-drush.git'",
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
        return $this->container->get('puphpet.extension.drush.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.drush.manifest_controller');
    }
}
