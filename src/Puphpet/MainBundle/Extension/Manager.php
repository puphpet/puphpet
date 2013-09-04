<?php

namespace Puphpet\MainBundle\Extension;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Manager
{
    /** @var Container */
    private $container;

    private $extensions = [];

    public function __construct(Container $container)
    {
        $this->container = $container;
    }

    /**
     * @param ExtensionInterface $extension
     * @return $this
     */
    public function addExtension(Extension\ExtensionInterface $extension)
    {
        $this->extensions[$extension->getName()] = $extension;

        return $this;
    }

    /**
     * @return array
     */
    public function getExtensions()
    {
        return $this->extensions;
    }

    /**
     * @return array
     */
    public function getParsed()
    {
        $parsed = [];

        /** @var Extension\ExtensionInterface $extension */
        foreach ($this->extensions as $extension) {
            $parsed[$extension->getName()] = $extension->getMainRender();
        }

        return $parsed;
    }
}
