<?php

namespace Puphpet\Domain\Configuration\Event\Listener;

use Puphpet\Domain\Configuration\Event\ConfigurationEvent;

class ConfigurationConverterListener
{
    /**
     * All configurations whose keys should be converter
     * (e.g symfony_version -> '[project][version]')
     *
     * @var array
     */
    private $mapping;

    /**
     * The edition's name the actual listener instance is only enabled for
     *
     * @var string
     */
    private $enabledForEdition;

    /**
     * @param string $enabledForEdition
     * @param array  $mapping
     */
    public function __construct($enabledForEdition, array $mapping)
    {
        $this->enabledForEdition = $enabledForEdition;
        $this->mapping = $mapping;
    }

    /**
     * @param ConfigurationEvent $event
     */
    public function onFilter(ConfigurationEvent $event)
    {
        if ($event->getEditionName() == $this->enabledForEdition) {
            foreach ($this->mapping as $oldKey => $newKey) {
                $event->replace($oldKey, $newKey);
            }
        }
    }
}
