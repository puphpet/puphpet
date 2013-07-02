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

    private $configurationModules = array();

    /**
     * Constructor
     *
     * @param EventDispatcherInterface $eventDispatcher
     * @param array                    $configurationModules all the modules which need custom modifications
     *                                                       to the domain file
     */
    public function __construct(EventDispatcherInterface $eventDispatcher, $configurationModules = array())
    {
        $this->eventDispatcher = $eventDispatcher;
        $this->configurationModules = $configurationModules;
    }

    /**
     * Runs through all registered configurators, asks them if they want
     * to modify the given domain file dependant on each configuration key
     * and if so let them do it.
     *
     * @param File  $domainFile
     * @param array $configuration
     */
    public function configure(File $domainFile, array &$configuration)
    {
        // @TODO these configuration modules should be added as listeners too
        foreach ($this->configurationModules as $configurator) {
            /** @var $configurator \Puphpet\Domain\Configurator\File\ConfiguratorInterface */
            if ($configurator->supports($configuration)) {
                $configurator->configure($domainFile, $configuration);
            }
        }

        // delegate configuration to listeners
        $event = new ConfiguratorEvent($domainFile, $configuration);

        $this->eventDispatcher->dispatch(Events::EVENT_FILE_CONFIGURATION, $event);
    }
}
