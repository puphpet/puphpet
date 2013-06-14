<?php

namespace Puphpet\Domain\File;

use Puphpet\Domain\Compiler\Manifest\ConfigurationFormatter;
use Puphpet\Domain\Configuration\Configuration;
use Symfony\Component\HttpFoundation\Request;

/**
 * Generator for domain file archive from given request
 */
class ConfigurationGenerator
{

    /**
     * @var Generator
     */
    private $generator;

    /**
     * @var ConfigurationFormatter
     */
    private $configurationFormatter;

    /**
     * @param Generator $generator
     * @param ConfigurationFormatter $configurationFormatter
     */
    public function __construct(Generator $generator, ConfigurationFormatter $configurationFormatter)
    {
        $this->generator = $generator;
        $this->configurationFormatter = $configurationFormatter;
    }

    /**
     * Extracts and formats request params and converts a domain file from it
     *
     * @param Configuration $configuration
     *
     * @return \Puphpet\Domain\File
     */
    public function generateArchive(Configuration $configuration)
    {
        // extracting box configuration
        $box = $configuration->get('box');
        $boxConfiguration = ['box' => $box];

        // extracting manifest configuration
        $this->configurationFormatter->bindConfiguration($configuration);
        $manifestConfiguration = $this->configurationFormatter->format();

        // building vagrant configuration
        $vagrantConfiguration = array_merge(
            $boxConfiguration,
            ['mysql' => $manifestConfiguration['mysql']]
        );

        return $this->generator->generateArchive(
            $boxConfiguration,
            $manifestConfiguration,
            $vagrantConfiguration
        );
    }
}