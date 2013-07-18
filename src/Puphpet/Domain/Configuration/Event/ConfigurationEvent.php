<?php

namespace Puphpet\Domain\Configuration\Event;

use Puphpet\Domain\File;
use Symfony\Component\EventDispatcher\Event;

/**
 * Event which is thrown during transforming user configuration
 */
class ConfigurationEvent extends Event
{

    /**
     * The edition's name.
     * The event is not allowed to have the Edition assigned (as every listener
     * could change the edition on its own), however we need at least the edition name
     * so listeners could be triggered correctly.
     *
     * @var string
     */
    private $editionName;

    /**
     * @param string $editionName
     * @param array $configuration the original configuration
     */
    public function __construct($editionName, array $configuration)
    {
        $this->editionName = $editionName;
        $this->configuration = $configuration;
    }

    /**
     * @return string
     */
    public function getEditionName()
    {
        return $this->editionName;
    }

    /**
     * @return array the transformed configuration
     */
    public function getConfiguration()
    {
        return $this->configuration;
    }

    /**
     * Replaces a configuration key with another one.
     * Useful when a configuration key should be changed
     * to a property accessor (e.g create_project -> [project][generate_project]).
     *
     * @param string $oldKey
     * @param string $newKey
     */
    public function replace($oldKey, $newKey)
    {
        if (array_key_exists($oldKey, $this->configuration)) {

            $value = $this->configuration[$oldKey];

            unset($this->configuration[$oldKey]);
            $this->configuration[$newKey] = $value;
        } else {
            $this->configuration[$newKey] = null;
        }
    }
}