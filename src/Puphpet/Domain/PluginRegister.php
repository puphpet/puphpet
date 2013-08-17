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
}
