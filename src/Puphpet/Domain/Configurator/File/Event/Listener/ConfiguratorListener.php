<?php

namespace Puphpet\Domain\Configurator\File\Event\Listener;


use Puphpet\Domain\Configurator\File\ConfiguratorInterface;
use Puphpet\Domain\Configurator\File\Event\ConfiguratorEvent;

class ConfiguratorListener
{
    /**
     * @var ConfiguratorInterface
     */
    private $configurators;

    /**
     * @param mixed $configurator one ConfiguratorInterface or a list of them
     */
    public function __construct($configurators)
    {
        $this->configurators = is_array($configurators) ? $configurators : [$configurators];
    }

    /**
     * @param ConfiguratorEvent $event
     */
    public function onConfigure(ConfiguratorEvent $event)
    {
        $configuration = $event->getConfiguration();

        foreach ($this->configurators as $configurator) {
            if (!$configurator instanceof ConfiguratorInterface) {
                $msg = sprintf(
                    'ConfiguratorListener supports instances of ConfiguratorInterface only'
                    . ', given "%s"',
                    get_class($configurator)
                );
                throw new \InvalidArgumentException($msg);
            }
            if ($configurator->supports($configuration)) {
                $configurator->configure($event->getDomainFile(), $configuration);
            }
        }
    }
}