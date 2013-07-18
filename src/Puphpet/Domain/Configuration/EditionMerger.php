<?php

namespace Puphpet\Domain\Configuration;

use Puphpet\Domain\Configuration\Event\ConfigurationEvent;
use Puphpet\Domain\Event\Events;
use Symfony\Component\EventDispatcher\EventDispatcherInterface;

/**
 * Merges the custom requested configuration into pre-configured edition.
 */
class EditionMerger
{

    /**
     * @var EventDispatcherInterface
     */
    private $dispatcher;

    /**
     * @param EventDispatcherInterface $dispatcher
     */
    public function __construct(EventDispatcherInterface $dispatcher)
    {
        $this->dispatcher = $dispatcher;
    }

    /**
     * @param Edition $edition
     * @param array   $customConfiguration
     *
     * @return void modifies assigned Edition instance directly
     *
     */
    public function merge(Edition $edition, array $customConfiguration)
    {
        // not every configuration is allowed to be overwritten by user configuration
        // therefore we have to filter the configuration first
        $event = new ConfigurationEvent($edition->getName(), $customConfiguration);
        $this->dispatcher->dispatch(Events::EVENT_CONFIGURATION_FILTER, $event);

        $filteredConfiguration = $event->getConfiguration();

        foreach ($filteredConfiguration as $key => $value) {
            $edition->set($key, $value);
        }
    }
}
