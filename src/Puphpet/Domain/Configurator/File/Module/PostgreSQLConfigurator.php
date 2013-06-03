<?php

namespace Puphpet\Domain\Configurator\File\Module;

use Puphpet\Domain\Configurator\File\ConfiguratorInterface;
use Puphpet\Domain\File;

class PostgreSQLConfigurator implements ConfiguratorInterface
{
    private $vendorPath;

    /**
     * @param string $vendorPath
     */
    public function __construct($vendorPath)
    {
        $this->vendorPath = $vendorPath;
    }

    /**
     * Configures the domain file to custom needs
     *
     * @param File  $domainFile
     * @param array $configuration
     *
     * @return void
     */
    public function configure(File $domainFile, array &$configuration)
    {
        $domainFile->addModuleSource('postgresql', $this->vendorPath . '/puppetlabs/postgresql');
    }

    /**
     * Signals if the configurator wants to configure the domain file
     * dependant on assigned configuration
     *
     * @param array $configuration
     *
     * @return bool
     */
    public function supports(array &$configuration)
    {
        if (array_key_exists('database', $configuration) && 'postgresql' == $configuration['database']) {
            if (array_key_exists('postgresql', $configuration) && is_array($configuration['postgresql'])) {
                return true;
            }
        }

        return false;
    }
}
