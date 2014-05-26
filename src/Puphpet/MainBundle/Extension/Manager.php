<?php

namespace Puphpet\MainBundle\Extension;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;
use Symfony\Component\Yaml\Yaml;

class Manager
{
    /** @var array */
    private $alreadyIterated = [];

    /** @var Extension\Archive */
    private $archive;

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
        $this->extensions[$extension->getSlug()] = $extension;

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

        $this->groups[$groupName][] = $extension->getSlug();
        $this->groupsMirrored[$extension->getSlug()] = $groupName;

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
     * @param $slug
     * @return ExtensionInterface
     */
    public function getExtensionBySlug($slug)
    {
        return $this->extensions[$slug];
    }

    /**
     * @return array
     */
    public function getAllParsed()
    {
        $parsed = [];

        foreach ($this->extensions as $extension) {
            $parsed[$extension->getSlug()] = $extension;
        }

        return $parsed;
    }

    /**
     * Takes associative array and discards any keys not matching a registered
     * extension slug
     *
     * @param array $values
     * @return array
     */
    public function matchExtensionToArrayValues(array $values)
    {
        $validExtensions = [];

        foreach ($this->extensions as $extension) {
            if (array_key_exists($extension->getSlug(), $values)) {
                $validExtensions[$extension->getSlug()] = $values[$extension->getSlug()];
            }
        }

        return $validExtensions;
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

    /**
     * @param array $request
     * @return string
     */
    public function createArchive(array $request)
    {
        $submittedExtensions = $this->matchExtensionToArrayValues($request);

        $this->archive = new Extension\Archive;

        $extensions = [];
        $sources = [];
        $mergedData = [];

        foreach ($submittedExtensions as $slug => $data) {
            $extension = $this->getExtensionBySlug($slug);
            $extension->setCustomData($data);

            $extensions[$slug] = $extension;

            $extension->setReturnAvailableData(false);

            $this->archive->queueToFile(
                $extension->getTargetFile(),
                $extension->renderManifest($extension->getData())
            );

            foreach ($extension->getSources() as $name => $source) {
                $sources[$name] = $source;
            }

            $mergedData[$slug] = $extension->getData(false);
        }

        $this->processExtensionSources($sources);

        $this->archive->queueToFile(
            'puphpet/config.yaml',
            Yaml::dump($mergedData, 50)
        );

        $this->archive->addFolder(
            __DIR__ . '/../../../../modules',
            'puphpet/puppet/modules'
        );

        $this->archive->write();

        return $this->archive->zip();
    }

    /**
     * Accepts custom data for all possible extensions
     *
     * @param yaml $data
     * @return bool
     */
    public function setCustomDataAll($data)
    {
        foreach ($this->extensions as $extension) {
            if (empty($data[$extension->getSlug()])) {
                continue;
            }

            $extension->setCustomData($data[$extension->getSlug()]);
        }

        return true;
    }

    private function processExtensionSources(array $sources)
    {
        foreach ($sources as $name => $source) {
            if (empty($name)) {
                continue;
            }

            $result = "mod '{$name}'";

            if (!empty($source)) {
                $result .= ", {$source}";
            }

            $this->archive->queueToFile('puphpet/puppet/Puppetfile', $result);
        }
    }
}
