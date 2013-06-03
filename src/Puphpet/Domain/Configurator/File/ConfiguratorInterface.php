<?php

namespace Puphpet\Domain\Configurator\File;

use Puphpet\Domain\File;

interface ConfiguratorInterface
{
    /**
     * Configures the domain file to custom needs
     *
     * @param File  $domainFile
     * @param array $configuration
     *
     * @return void
     */
    public function configure(File $domainFile, array &$configuration);

    /**
     * Signals if the configurator wants to configure the domain file
     * dependant on assigned configuration
     *
     * @param array $configuration
     *
     * @return bool
     */
    public function supports(array &$configuration);
}
