<?php

namespace Puphpet\Domain;

use Pimple;

class PluginRegister
{
    /** @var Pimple */
    private $bucket;

    /**
     * @param Pimple $bucket
     */
    public function __construct(Pimple $bucket)
    {
        $this->bucket = $bucket;
    }

    /**
     * Save plugin in bucket
     *
     * @param PluginInterface $plugin Plugin object
     * @return self
     */
    public function register(PluginInterface $plugin)
    {
        $this->bucket[$plugin->getName()] = $this->bucket->share(function($c) use($plugin) {
            return $plugin;
        });

        return $this;
    }

    /**
     * Return plugin bucket
     *
     * @return Pimple
     */
    public function getPlugins()
    {
        return $this->bucket;
    }
}
