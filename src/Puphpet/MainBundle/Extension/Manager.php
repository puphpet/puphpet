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

    /** @var array */
    protected $extensions = [];

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
        $data       = array_merge($data, $available);

        $this->extensions[$name] = [
            'defaults' => $defaults,
            'data'     => $data,
            'merged'   => $mergedData,
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
     * @param array $data
     * @return string
     */
    public function createArchive(array $data)
    {
        $this->archive = new Extension\Archive;
        $this->archive->queueToFile(
            'puphpet/config.yaml',
            Yaml::dump($data, 50, 2)
        );

        $this->archive->write();

        return $this->archive->zip();
    }

    /**
     * Accepts custom data for all possible extensions
     *
     * @param array $data
     * @return bool
     */
    public function setCustomDataAll($data)
    {
        $skipVagrantfile = false;

        foreach ($this->extensions as $name => $extension) {
            $formattedName = $name;

            if (stristr($name, 'vagrantfile') !== false) {
                if ($skipVagrantfile) {
                    continue;
                }

                $formattedName = 'vagrantfile';
                $skipVagrantfile = true;
            }

            if (empty($data[$formattedName])) {
                continue;
            }

            $mergedData = array_replace_recursive($this->extensions[$name]['data'], $data[$formattedName]);

            $this->extensions[$name]['merged'] = $mergedData;
        }

        return true;
    }
}
