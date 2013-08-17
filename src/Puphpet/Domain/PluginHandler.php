<?php

namespace Puphpet\Domain;

use \Exception;

class PluginHandler
{
    /** @var array */
    private $data = [];

    /**
     * @var PluginRegister
     */
    private $pluginRegister;

    /**
     * @param PluginRegister $pluginRegister
     */
    public function __construct(PluginRegister $pluginRegister)
    {
        $this->pluginRegister = $pluginRegister;
    }

    /**
     * @param array $data
     * @return self
     */
    public function setData(array $data)
    {
        $this->data = $data;

        return $this;
    }

    /**
     * @return self
     */
    public function process()
    {
        foreach ($this->data as $pluginName => $pluginData) {
            $pluginName = ucfirst($pluginName);

            $pluginClass = "\\Puphpet\\Plugin\\{$pluginName}\\Register";

            $this->checkPluginExists($pluginClass);

            $plugin = new $pluginClass($pluginData);

            $this->pluginRegister->register($plugin);
        }

        return $this;
    }

    /**
     * Checks if plugin class exists
     *
     * @param string $pluginClass
     * @return bool
     * @throws Exception
     */
    private function checkPluginExists($pluginClass)
    {
        if (!class_exists($pluginClass)) {
            throw new Exception("Plugin {$pluginClass} does not exist");
        }

        return true;
    }
}
