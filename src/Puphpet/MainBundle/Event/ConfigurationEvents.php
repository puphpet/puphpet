<?php

namespace Puphpet\MainBundle\Event;

final class ConfigurationEvents
{
    /**
     * Used just before user data is bound to an extension
     */
    const EXTENSION_PRE_BIND = 'configuration.extension.pre_bind';

    private function __construct()
    {
    }
} 
