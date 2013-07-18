<?php

namespace Puphpet\Domain\Event;

abstract class Events
{
    /**
     * Is fired from ConfiguratorHandler and gives listeners
     * possibility to modify the domain file.
     */
    const EVENT_FILE_CONFIGURATION = 'file.configuration';

    /**
     * Is fired before user configuration is merged into edition configuration
     * and gives listeners the possibility to modify/clean the user configuration
     */
    const EVENT_CONFIGURATION_FILTER = 'configuration.filter';
}