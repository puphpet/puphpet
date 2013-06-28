<?php

namespace Puphpet\Domain\Configurator\File\Event;

use Puphpet\Domain\File;
use Symfony\Component\EventDispatcher\Event;

/**
 * Event which is thrown during archive file configuration
 */
class ConfiguratorEvent extends Event
{

    /**
     * @var File
     */
    private $domainFile;

    /**
     * @var array
     */
    private $configuration;

    /**
     * @param File  $domainFile
     * @param array $configuration
     */
    public function __construct(File $domainFile, array &$configuration)
    {
        $this->domainFile = $domainFile;
        $this->configuration = $configuration;
    }

    /**
     * @return array
     */
    public function getConfiguration()
    {
        return $this->configuration;
    }

    /**
     * @return File
     */
    public function getDomainFile()
    {
        return $this->domainFile;
    }
}