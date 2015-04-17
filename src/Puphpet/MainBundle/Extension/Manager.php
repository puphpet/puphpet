<?php

namespace Puphpet\MainBundle\Extension;

use Puphpet\MainBundle\Extension;

use Symfony\Component\Yaml\Yaml;

class Manager
{
    /** @var Extension\Archive */
    protected $archive;

    /** @var string Base path to config files */
    protected $confDir;

    /** @var array */
    protected $extensions = [];

    public function __construct()
    {
        $this->confDir = __DIR__ . '/../Resources/config';
    }

    /**
     * @param string $name
     * @return $this
     */
    public function addExtension($name)
    {
        $confDir = sprintf('%s/%s', $this->confDir, $name);
        $name    = str_replace('-', '_', $name);

        $data      = $this->yamlParse($confDir . '/data.yml');
        $defaults  = $this->yamlParse($confDir . '/defaults.yml');
        $available = $this->yamlParse($confDir . '/available.yml');

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
            $this->yamlDump($data, 50, 2)
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
        $vagrantfileTarget = empty($data['vagrantfile']['target']) ? 'local' : $data['vagrantfile']['target'];

        foreach ($this->extensions as $name => $extension) {
            $formattedName = $name;

            // Current loop is on a vagrantfile-* key
            if (stristr($name, 'vagrantfile') !== false) {
                // Current loop is NOT what was chosen in custom target
                if (stristr($name, $vagrantfileTarget) === false) {
                    $this->extensions[$name]['merged']['target'] = false;

                    continue;
                }

                $this->extensions[$name]['merged']['target'] = $vagrantfileTarget;

                $formattedName = 'vagrantfile';
            }

            if (empty($data[$formattedName])) {
                continue;
            }

            $mergedData = array_replace_recursive($this->extensions[$name]['data'], $data[$formattedName]);

            $this->extensions[$name]['merged'] = $mergedData;
        }

        return true;
    }

    protected function yamlParse($file)
    {
        return Yaml::parse($file, true);
    }

    protected function yamlDump($data)
    {
        return Yaml::dump($data, 50, 2);
    }
}
