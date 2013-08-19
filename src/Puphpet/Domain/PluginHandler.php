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
    private $bucket;

    /** @var Twig_Environment */
    private $twig;

    /**
     * @param PluginRegister   $pluginRegister
     * @param Twig_Environment $twig
     */
    public function __construct(PluginRegister $pluginRegister, Twig_Environment $twig)
    {
        $this->bucket = $pluginRegister;
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
            $this->registerPlugin($pluginName, $pluginData);
        }

        return $this->parse();
    }

    public function registerPlugin($name, $data)
    {
        $name = ucfirst($name);

        $class = "\\Puphpet\\Plugin\\{$name}\\Register";

        $this->checkPluginExists($class);

        $this->bucket->register(new $class($data));
    }

    /**
     * Return all registered plugins
     *
     * @return array
     */
    public function getPlugins()
    {
        $plugins = [];
        $bucket = $this->bucket->getPlugins();

        foreach ($bucket->keys() as $plugin) {
            $plugins[$plugin] = $bucket[$plugin];
        }

        return $plugins;
    }

    /**
     * @return self
     */
    protected function parse()
    {
        /** @var PluginInterface $plugin */
        foreach ($this->getPlugins() as $plugin) {
            $plugin->setParsedTemplate($this->parseTemplatesInOrder($plugin));
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

    /**
     * @param PluginInterface $plugin
     * @return string
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
