<?php

namespace Puphpet\Domain\Configurator\File\Event\Listener;


use Puphpet\Domain\Configurator\File\ConfiguratorInterface;
use Puphpet\Domain\Configurator\File\Event\ConfiguratorEvent;

class ConfiguratorListener
{
    /**
     * @var ConfiguratorInterface
     */
    private $configurator;

    /**
     * @param ConfiguratorInterface $configurator
     */
    public function __construct(ConfiguratorInterface $configurator)
    {
        $this->configurator = $configurator;
    }

    /**
     * @param ConfiguratorEvent $event
     */
    public function onConfigure(ConfiguratorEvent $event)
    {
        $configuration = $event->getConfiguration();

        if ($this->configurator->supports($configuration)) {
            $this->configurator->configure($event->getDomainFile(), $configuration);
        }
    }
}