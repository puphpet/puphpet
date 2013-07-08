<?php

namespace Puphpet\Domain\Configurator\File;

use Puphpet\Domain\Decider\DeciderInterface;
use Puphpet\Domain\File;

/**
 * Adds additional puppet modules to domain file
 */
class SourceAddingConfigurator implements ConfiguratorInterface
{
    /**
     * @var DeciderInterface
     */
    private $decider;

    /**
     * @var array
     */
    private $moduleMapping;

    /**
     * @param DeciderInterface $decider
     * @param array            $moduleMapping target module as key and vendor module path as value
     */
    public function __construct(DeciderInterface $decider, $moduleMapping)
    {
        $this->decider = $decider;
        $this->moduleMapping = $moduleMapping;
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
        foreach ($this->moduleMapping as $targetModuleName => $vendorModulePath) {
            $domainFile->addModuleSource($targetModuleName, $vendorModulePath);
        }
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
        return $this->decider->supports($configuration);
    }
}
