<?php

namespace Puphpet\Extension\RubyBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Ruby';
    protected $slug = 'ruby';
    protected $targetFile = 'puphpet/puppet/nodes/ruby.pp';

    protected $sources = [
        'rvm' => ":git => 'https://github.com/maestrodev/puppet-rvm.git'",
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
        return $this->container->get('puphpet.extension.ruby.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.ruby.manifest_controller');
    }
}
