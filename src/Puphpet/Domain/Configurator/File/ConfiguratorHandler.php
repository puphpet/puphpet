<?php

namespace Puphpet\Domain\Configurator\File;

use Puphpet\Domain\File;

/**
 * Provides possibility to modify and configure the domain file
 */
class ConfiguratorHandler
{
    private $configurationModules = array();

    /**
     * Constructor
     *
     * @param array $configurationModules all the modules which need custom modifications
     *                                    to the domain file
     */
    public function __construct($configurationModules = array())
    {
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
        foreach ($this->configurationModules as $configurator) {
            /** @var $configurator \Puphpet\Domain\Configurator\File\ConfiguratorInterface */
            if ($configurator->supports($configuration)) {
                $configurator->configure($domainFile, $configuration);
            }
        }
    }
}
