<?php

namespace Puphpet\MainBundle\EventListener;

use Puphpet\MainBundle\Event\ConfigurationEvent;

abstract class MixinConfigurationListener
{
    public function onPreBind(ConfigurationEvent $event)
    {
        if ($this->supports($event->getConfiguration())) {
            $newData = $this->mixin($event->getConfiguration(), $event->getData());
            $event->setData($newData);
        }
    }

    /**
     * Whether the listener should run with given configuration
     *
     * @param array $configuration
     *
     * @return bool
     */
    abstract protected function supports(array $configuration);

    /**
     * Generates new user configuration data from given configuration.
     * Useful if one extension needs configuration from another one.
     *
     * @param array $configuration
     * @param array $data
     *
     * @return array
     */
    abstract protected function mixin(array $configuration, array $data);
}
