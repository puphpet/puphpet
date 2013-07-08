<?php

namespace Puphpet\Domain\Configurator\File;

use Puphpet\Domain\Configurator\File\Event\ConfiguratorEvent;
use Puphpet\Domain\Event\Events;
use Puphpet\Domain\File;
use Symfony\Component\EventDispatcher\EventDispatcherInterface;

/**
 * Provides possibility to modify and configure the domain file
 */
class ConfiguratorHandler
{
    /**
     * @var EventDispatcherInterface
     */
    private $eventDispatcher;

    /**
     * Constructor
     *
     * @param EventDispatcherInterface $eventDispatcher
     */
    public function __construct(EventDispatcherInterface $eventDispatcher)
    {
        $this->eventDispatcher = $eventDispatcher;
    }

    /**
     * Delegates file configuration to listeners.
     *
     * @param File  $domainFile
     * @param array $configuration
     */
    public function configure(File $domainFile, array &$configuration)
    {
        // delegate configuration to listeners
        $event = new ConfiguratorEvent($domainFile, $configuration);

        $this->eventDispatcher->dispatch(Events::EVENT_FILE_CONFIGURATION, $event);
    }
}
