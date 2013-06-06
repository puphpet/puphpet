<?php

namespace Puphpet\Domain;

use Puphpet\Domain;

class File extends Domain
{
    private $sysTempDir;
    private $tmpFolder;
    private $tmpPath;
    private $source;

    /**
     * Absolute filename to tmp archive without extension
     *
     * @var string
     */
    private $archiveFile;

    /**
     * Absolute file name to tmp archive path including extension
     *
     * @var string
     */
    private $archivePath;
    private $moduleSources = array();

    /**
     * @var Filesystem
     */
    private $filesystem;

    /**
     * @var string
     */
    private $name;

    /**
     * @param string     $source Absolute path to archive
     * @param Filesystem $filesystem
     */
    public function __construct($source, Filesystem $filesystem)
    {
        $this->source = $source;
        $this->filesystem = $filesystem;
    }

    /**
     * Assigns target file name
     *
     * @param string $name
     */
    public function setName($name)
    {
        $this->name = $name;
    }

    /**
     * @return string
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * @param array $replacementFiles Files to replace in our source folder
     *
     * @return string Path to generated file
     */
    public function createArchive(array $replacementFiles = array())
    {
        $this->setPaths();
        $this->copyToTempFolder();
        $this->cleanupFiles();

        foreach ($replacementFiles as $path => $content) {
            $this->copyFile($path, $content);
        }

        $this->zipFolder();
    }

    /**
     * Returns absolute path to created (zip) archive
     *
     * @return string
     */
    public function getArchivePath()
    {
        return $this->archivePath;
    }

    /**
     * Paths on server
     */
    protected function setPaths()
    {
        $this->sysTempDir = $this->getSysTempDir();
        $this->tmpFolder = $this->getTmpFolder();
        $this->tmpPath = $this->sysTempDir . '/' . $this->tmpFolder;
        $this->archiveFile = $this->getTmpFile($this->sysTempDir, $this->tmpFolder);
        $this->archivePath = $this->archiveFile . '.zip';
    }

    /**
     * Copy our repo to a temp file
     */
    protected function copyToTempFolder()
    {
        // copy main source
        $this->copySource($this->source, $this->tmpPath);

        // copy all optional sources
        foreach ($this->moduleSources as $moduleName => $moduleSource) {
            // this copies the module into the clone of the original source
            // which must contain a "modules" folder
            $this->copySource($moduleSource, $this->tmpPath . '/modules/' . $moduleName);
        }
    }

    /**
     * Removes and replaces all files from vagrant-puppet-lamp which may confuse the user
     * and does not belong directly to the custom vagrant/puppet environment
     */
    protected function cleanupFiles()
    {
        // remove unneeded files
        $this->filesystem->remove($this->tmpPath.'/composer.json');
        $this->filesystem->remove($this->tmpPath.'/README.md');
    }

    /**
     * Adds a puppet module to the archive
     *
     * @param string $moduleName   the module name
     * @param string $moduleSource absolute path of a puppet module
     */
    public function addModuleSource($moduleName, $moduleSource)
    {
        $this->moduleSources[$moduleName] = $moduleSource;
    }

    /**
     * Copies given source to assigned target
     *
     * @param string $sourcePath absolute source path
     * @param string $targetPath absolute target path
     */
    protected function copySource($sourcePath, $targetPath)
    {
        $this->filesystem->mirror($sourcePath, $targetPath);
    }

    /**
     * Replace existing file in source folder
     *
     * @param string $path Path to file within source folder to replace
     * @param string $file Content to replace file with
     */
    protected function copyFile($path, $file)
    {
        $this->filesystem->putContents($this->tmpPath . '/' . $path, $file);
    }

    /**
     * Create a zip archive
     */
    protected function zipFolder()
    {
        $this->filesystem->createArchive($this->archivePath, $this->tmpPath);
    }

    /**
     * @return string
     */
    protected function getSysTempDir()
    {
        return $this->filesystem->getSysTempDir();
    }

    protected function getTmpFolder()
    {
        return $this->filesystem->getTmpFolder();
    }

    protected function getTmpFile($dir, $prefix)
    {
        return $this->filesystem->getTmpFile($dir, $prefix);
    }
}
