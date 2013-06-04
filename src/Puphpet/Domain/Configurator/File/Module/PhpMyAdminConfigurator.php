<?php

namespace Puphpet\Domain\Configurator\File\Module;

use Puphpet\Domain\Configurator\File\ConfiguratorInterface;
use Puphpet\Domain\File;

class PhpMyAdminConfigurator implements ConfiguratorInterface
{
    /**
     * @var string
     */
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
        $domainFile->addModuleSource(
            'phpmyadmin',
            $this->vendorPath . '/frastel/puppet-phpmyadmin'
        );
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
        if (array_key_exists('mysql', $configuration)
            && array_key_exists('phpmyadmin', $configuration['mysql'])
        ) {
            return (bool) $configuration['mysql']['phpmyadmin'];
        }

        return false;
    }
}
