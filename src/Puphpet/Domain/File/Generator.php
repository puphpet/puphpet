<?php

namespace Puphpet\Domain\File;

use Puphpet\Domain\Compiler\Compiler;
use Puphpet\Domain\Serializer\Serializer;
use Puphpet\Domain\Configurator\File\ConfiguratorHandler;
use Puphpet\Domain\File;

/**
 * Generator for domain file archive
 */
class Generator
{
    /**
     * @var Compiler
     */
    private $vagrantCompiler;

    /**
     * @var Compiler
     */
    private $manifestCompiler;

    /**
     * @var Compiler
     */
    private $readmeCompiler;

    /**
     * @var File
     */
    private $domainFile;

    /**
     * @var ConfiguratorHandler
     */
    private $fileConfigurator;

    /**
     * @var Serializer
     */
    private $serializer;

    /**
     * @param Compiler            $vagrantCompiler
     * @param Compiler            $manifestCompiler
     * @param Compiler            $readmeCompiler
     * @param File                $domainFile
     * @param ConfiguratorHandler $fileConfigurator
     * @param Serializer          $serializer
     */
    public function __construct(
        Compiler $vagrantCompiler,
        Compiler $manifestCompiler,
        Compiler $readmeCompiler,
        File $domainFile,
        ConfiguratorHandler $fileConfigurator,
        Serializer $serializer
    ) {
        $this->vagrantCompiler = $vagrantCompiler;
        $this->manifestCompiler = $manifestCompiler;
        $this->readmeCompiler = $readmeCompiler;
        $this->domainFile = $domainFile;
        $this->fileConfigurator = $fileConfigurator;
        $this->serializer = $serializer;
    }

    /**
     * Generates a domain file from given configuration
     *
     * @param array $boxConfiguration
     * @param array $manifestConfiguration
     * @param array $vagrantConfiguration
     * @param array $userConfiguration
     *
     * @return File
     */
    public function generateArchive(
        array $boxConfiguration,
        array $manifestConfiguration,
        array $vagrantConfiguration,
        array $userConfiguration
    ) {
        $this->domainFile->setName($boxConfiguration['box']['name'].'.zip');

        $manifest = $this->manifestCompiler->compile($manifestConfiguration);

        // build Vagrantfile
        $vagrantFile = $this->vagrantCompiler
            ->setTemplate('Vagrant/Vagrantfile/'. strtolower($boxConfiguration['box']['provider']) .'.twig')
            ->compile($vagrantConfiguration);

        // build and configure the domain file
        $this->fileConfigurator->configure($this->domainFile, $manifestConfiguration);

        $readme = $this->readmeCompiler->compile(
            array_merge($manifestConfiguration, $boxConfiguration)
        );

        $completeConfiguration = array_merge($manifestConfiguration, $boxConfiguration);

        //@TODO adding/replacing files to the archive could be done in configurators
        //@TODO as soon as the domain file supports adding single files
        // creating and building the archive
        $this->domainFile->createArchive(
            [
                'README'                  => $readme,
                'puphpet.json'            => $this->serializer->serialize($userConfiguration),
                'Vagrantfile'             => $vagrantFile,
                'manifests/default.pp'    => $manifest,
                'files/dot/.bash_aliases' => $manifestConfiguration['server']['bashaliases'],
            ]
        );

        return $this->domainFile;
    }
}
