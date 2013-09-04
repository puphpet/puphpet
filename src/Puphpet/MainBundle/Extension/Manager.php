<?php

namespace Puphpet\MainBundle\Extension;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Manager
{
    /** @var Container */
    private $container;

    /** @var array */
    private $extensions = [];

    /** @var array */
    private $groups = [];

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
     * Track extension and add to group
     *
     * @param string             $group
     * @param ExtensionInterface $extension
     * @return $this
     */
    public function addExtensionToGroup($group, Extension\ExtensionInterface $extension)
    {
        $this->groups[$group] = $extension->getName();

        return $this->addExtension($extension);
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
            $parsed[$extension->getName()] = $extension;
        }

        return $parsed;
    }
}
