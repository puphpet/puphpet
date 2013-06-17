<?php

namespace Puphpet\Domain\Configuration;

class Configuration
{
    private $configuration;

    /**
     * Constructor
     *
     * @param array $configuration
     */
    public function __construct(array $configuration)
    {
        $this->configuration = $configuration;
    }

    /**
     * @param string $key
     * @param string $default
     *
     * @return mixed
     */
    public function get($key, $default = null)
    {
        return array_key_exists($key, $this->configuration) ? $this->configuration[$key] : $default;
    }

    /**
     * Returns all configuration as array
     *
     * @return array
     */
    public function toArray()
    {
        return $this->configuration;
    }
}