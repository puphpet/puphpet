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
     * Extracts and formats request params and converts a domain file from it.
     * Receives the complete configuration and splits it into box, manifest and vagrant
     * configuration so that the file generator may handle it.
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
        $dbConfiguration = array();
        if (array_key_exists('mysql', $manifestConfiguration)) {
            $dbConfiguration['mysql'] = $manifestConfiguration['mysql'];
        }
        $vagrantConfiguration = array_merge(
            $boxConfiguration,
            $dbConfiguration
        );

        return $this->generator->generateArchive(
            $boxConfiguration,
            $manifestConfiguration,
            $vagrantConfiguration
        );
    }
}