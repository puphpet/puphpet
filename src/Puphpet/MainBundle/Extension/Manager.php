<?php

namespace Puphpet\MainBundle\Extension;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Manager
{
    /** @var array */
    private $alreadyIterated = [];

    /** @var Container */
    private $container;

    /** @var Extension\ExtensionInterface[] */
    private $extensions = [];

    /** @var array */
    private $groups = [];

    /** @var array */
    private $groupsMirrored = [];

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
     * @param string             $groupName
     * @param ExtensionInterface $extension
     * @return $this
     */
    public function addExtensionToGroup($groupName, Extension\ExtensionInterface $extension)
    {
        if (empty($this->groups[$groupName])) {
            $this->groups[$groupName] = [];
        }

        $this->groups[$groupName][] = $extension->getName();
        $this->groupsMirrored[$extension->getName()] = $groupName;

        $this->addExtension($extension);

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
    public function getAllParsed()
    {
        $parsed = [];

        foreach ($this->extensions as $extension) {
            $parsed[$extension->getName()] = $extension;
        }

        return $parsed;
    }

    /**
     * @param string $extensionName
     * @return string
     */
    public function belongsToGroup($extensionName)
    {
        if (array_key_exists($extensionName, $this->groupsMirrored)
            && !empty($this->groups[$this->groupsMirrored[$extensionName]])
        ) {
            return $this->groupsMirrored[$extensionName];
        }

        return false;
    }

    /**
     * @param $groupName
     * @return Extension\ExtensionInterface[]
     */
    public function getExtensionsInGroup($groupName)
    {
        if (empty($this->groups[$groupName])) {
            return [];
        }

        $this->alreadyIterated = array_merge(
            $this->alreadyIterated,
            array_values($this->groups[$groupName])
        );

        $extensions = [];

        foreach ($this->groups[$groupName] as $extensionName) {
            $extensions[$extensionName] = $this->extensions[$extensionName];
        }

        return $extensions;
    }

    /**
     * Returns only the names of extensions assigned to a particular group
     *
     * @param string $groupName
     * @return array
     */
    public function getExtensionNamesInGroup($groupName)
    {
        if (empty($this->groups[$groupName])) {
            return [];
        }

        return $this->groups[$groupName];
    }

    /**
     * Iterate through extensions in a group and figure out if any have custom data set
     *
     * This is useful to figure out which extension the user previously selected, so we can
     * assume that extension is the one the user wants to work with now
     *
     * If no extension has any custom data, returns the first extension of the group
     *
     * @param string $groupName
     * @return string
     */
    public function extensionInGroupHasCustomData($groupName)
    {
        if (empty($this->groups[$groupName])) {
            return false;
        }

        $firstExtension = null;

        foreach ($this->groups[$groupName] as $extensionName) {
            if (!$firstExtension) {
                $firstExtension = $extensionName;
            }

            if ($this->extensions[$extensionName]->hasCustomData()) {
                return $extensionName;
            }
        }

        return $firstExtension;
    }

    /**
     * Checks whether an extension has already been looped through,
     * useful for maintaining group structure
     *
     * @param string $extensionName
     * @return bool
     */
    public function extensionAlreadyUsed($extensionName)
    {
        if (in_array($extensionName, $this->alreadyIterated)) {
            return true;
        }

        return false;
    }
}
