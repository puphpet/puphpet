<?php

namespace Puphpet\Domain\Configuration;


class Configuration
{
    private $configuration;

    public function __construct(array $configuration)
    {
        $this->configuration = $configuration;
    }

    public function get($key, $default = null)
    {
        return array_key_exists($key, $this->configuration) ? $this->configuration[$key] : $default;
    }
}