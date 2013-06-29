<?php

namespace Puphpet\Domain\Configurator\File;

use Puphpet\Domain\Compiler\DeciderInterface;
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
     * @var string
     */
    private $targetModuleName;

    /**
     * @var string
     */
    private $vendorModulePath;

    /**
     * @param DeciderInterface $decider
     * @param string           $targetModuleName
     * @param string           $vendorModulePath
     */
    public function __construct(DeciderInterface $decider, $targetModuleName, $vendorModulePath)
    {
        $this->decider = $decider;
        $this->targetModuleName = $targetModuleName;
        $this->vendorModulePath = $vendorModulePath;
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
        $domainFile->addModuleSource($this->targetModuleName, $this->vendorModulePath);
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
