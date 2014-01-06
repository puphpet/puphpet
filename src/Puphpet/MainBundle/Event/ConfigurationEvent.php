<?php

namespace Puphpet\MainBundle\Event;

use Symfony\Component\EventDispatcher\Event;

class ConfigurationEvent extends Event
{
    /**
     * @param array $configuration the complete and raw user configuration
     * @param array $data          the user configuration data
     */
    public function __construct(array $configuration, array $data)
    {
        $this->configuration = $configuration;
        $this->data = $data;
    }

    public function setData(array $data)
    {
        $this->data = $data;
    }

    /**
     * @return array
     */
    public function getConfiguration()
    {
        return $this->configuration;
    }

    /**
     * @return array
     */
    public function getData()
    {
        return $this->data;
    }
} 
