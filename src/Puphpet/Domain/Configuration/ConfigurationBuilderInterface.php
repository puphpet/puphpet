<?php

namespace Puphpet\Domain\Configuration;

interface ConfigurationBuilderInterface
{
    /**
     * Builds configuration from given pre-configured edition and
     * custom user configuration.
     *
     * @param Edition $edition the system input
     * @param array   $customConfiguration the user input
     *
     * @return Configuration
     */
    public function build(Edition $edition, array $customConfiguration);
}