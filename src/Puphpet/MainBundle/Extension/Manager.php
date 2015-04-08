<?php

namespace Puphpet\MainBundle\Extension;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;
use Symfony\Component\Yaml\Yaml;

class Manager
{
    CONST CONF_DIR = __DIR__ . '/../Resources/config';

    /** @var Extension\Archive */
    protected $archive;

    /** @var Container */
    protected $container;

    /** @var array */
    protected $extensions = [];

    public function __construct(Container $container)
    {
        $this->container = $container;
    }

    /**
     * @param string $name
     * @return $this
     */
    public function addExtension($name)
    {
        $confDir = sprintf('%s/%s', self::CONF_DIR, $name);
        $name    = str_replace('-', '_', $name);

        $data      = Yaml::parse($confDir . '/data.yml');
        $defaults  = Yaml::parse($confDir . '/defaults.yml');
        $available = Yaml::parse($confDir . '/available.yml');

        $data      = is_array($data) ? $data : [];
        $defaults  = is_array($defaults) ? $defaults : [];
        $available = is_array($available) ? $available : [];

        $mergedData = array_replace_recursive($data, $defaults);
        $mergedData = array_merge($mergedData, $available);

        $this->extensions[$name] = [
            'data' => $mergedData,
        ];

        return $this;
    }

    /**
     * @param string $name
     * @return array
     */
    public function getExtension($name)
    {
        $name = str_replace('-', '_', $name);

        return $this->extensions[$name];
    }

    /**
     * @return array
     */
    public function getExtensions()
    {
        return $this->extensions;
    }

    /**
     * @param string $name
     * @return array
     */
    public function getExtensionData($name)
    {
        $name = str_replace('-', '_', $name);

        return $this->extensions[$name]['data'];
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

            $mergedData[$slug] = $extension->getData(false);
        }

        $this->archive->queueToFile(
            'puphpet/config.yaml',
            Yaml::dump($mergedData, 50)
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
                $baseData = $extension->getBaseData();

                if (!array_key_exists('install', $baseData)) {
                    continue;
                }

                $data[$extension->getSlug()] = $baseData;
            }

            $extension->setCustomData($data[$extension->getSlug()]);
        }

        return true;
    }
}
