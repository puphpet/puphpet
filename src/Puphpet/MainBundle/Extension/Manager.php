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

    public function __construct($confDir = __DIR__ . '/../Resources/config')
    {
        $this->confDir = $confDir;
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

        $this->extensions[$name] = [
            'available' => $available,
            'data'      => $data,
            'defaults'  => $defaults,
            'merged'    => $mergedData,
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
     * @param string $name
     * @return array
     */
    public function getExtensionAvailableData($name)
    {
        $name = str_replace('-', '_', $name);

        return $this->extensions[$name]['available'];
    }

    /**
     * @param array $data
     * @return string
     */
    public function createArchive(array $data)
    {
        foreach ($data as $key => $values) {
            $name = $this->parseDataKeyName($values, $key);

            $data[$key] = array_replace_recursive($this->extensions[$name]['data'], $data[$key]);
        }

        $this->archive = new Extension\Archive;
        $this->archive->queueToFile(
            'puphpet/config.yaml',
            $this->yamlDump($data)
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
        foreach ($this->extensions as $name => $extension) {
            if (!$formattedName = $this->vagrantfileHandling($data, $name)) {
                continue;
            }

            if (empty($data[$formattedName])) {
                continue;
            }

            $mergedData = array_replace_recursive(
                $this->extensions[$name]['data'],
                $data[$formattedName]
            );

            $this->extensions[$name]['merged'] = $mergedData;
        }

        return true;
    }

    /**
     * Figures out which Vagrantfile extension was selected in config file.
     *
     * The vagrantfile config key does not tell us which extension was selected,
     * eg "vagrantfile-rackspace" or "vagrantfile-digitalocean". The best way to
     * figure out which target was originally selected is by reading the
     * "vagrantfile.target" value.
     *
     * While looping, if current $name value is not the vagrantfile extension name
     * chosen, set the "vagrantfile-$name.target" value to "false" so we can
     * properly reflect choice in the GUI.
     *
     * If current $name value is chosen vagrantfile extension, set
     * "vagrantfile-$name.target" value to $name to properly reflect choice in
     * the GUI.
     *
     * @param array  $data Custom data
     * @param string $name Name of current extension in loop
     * @return bool|string
     */
    protected function vagrantfileHandling($data, $name)
    {
        /**
         * If "vagrantfile.target" value was not originally set in config,
         * default to "local". This handles config files created before
         * v5 redesign.
         */
        $vagrantfileTarget = empty($data['vagrantfile']['target'])
            ? 'local'
            : $data['vagrantfile']['target'];

        // Current loop is on a vagrantfile-* key
        if (stristr($name, 'vagrantfile') !== false) {
            // Current loop is NOT what was chosen in custom target
            if (stristr($name, $vagrantfileTarget) === false) {
                $this->extensions[$name]['merged']['target'] = false;

                return false;
            }

            $this->extensions[$name]['merged']['target'] = $vagrantfileTarget;

            return 'vagrantfile';
        }

        return $name;
    }

    protected function parseDataKeyName($data, $name)
    {
        if (stristr($name, 'vagrantfile') !== false) {
            return sprintf('vagrantfile_%s', $data['target']);
        }

        return $name;
    }

    protected function yamlParse($file)
    {
        return Yaml::parse($file, true);
    }

    protected function yamlDump($data)
    {
        return Yaml::dump($data, 50, 4);
    }
}
