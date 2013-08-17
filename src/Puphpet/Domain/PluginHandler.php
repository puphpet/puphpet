<?php

namespace Puphpet\Domain;

use \Twig_Environment;
use \Exception;

class PluginHandler
{
    /** @var array */
    private $data = [];

    /**
     * @var PluginRegister
     */
    private $pluginRegister;

    /** @var Twig_Environment */
    private $twig;

    /**
     * @param PluginRegister   $pluginRegister
     * @param Twig_Environment $twig
     */
    public function __construct(PluginRegister $pluginRegister, Twig_Environment $twig)
    {
        $this->pluginRegister = $pluginRegister;
        $this->twig = $twig;
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
     * Return all registered plugins
     *
     * @return array
     */
    public function getPlugins()
    {
        $plugins = [];
        $bucket = $this->pluginRegister->getPlugins();

        foreach ($bucket->keys() as $plugin) {
            $plugins[$plugin] = $bucket[$plugin];
        }

        return $plugins;
    }

    public function parse()
    {
        $rendered = '';

        foreach ($this->getPlugins() as $plugin) {
            $rendered.= $this->parseTemplatesInOrder($plugin);
        }

        return $rendered;
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

    /**
     * @param PluginInterface $plugin
     */
    private function parseTemplatesInOrder(PluginInterface $plugin)
    {
        $pluginName = ucfirst($plugin->getName());

        $rendered = '';
        foreach ($plugin->getTemplateOrder() as $template) {
            $rendered.= $this->twig->render(
                "{$pluginName}/Template/{$template}.twig",
                $plugin->getData()
            );
        }

        return $rendered;
    }
}
