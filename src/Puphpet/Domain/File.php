<?php

namespace Puphpet\Domain;

use Puphpet\Domain;

class File extends Domain
{

    /**
     * Absolute filename to tmp archive without extension
     *
     * @var string
     */
    private $archivePath;

    /**
     * Path that will contain our path to be zipped.
     *
     * Helps prevent zipbombs (all folders/files extracted to current directory instead of in container directory)
     *
     * @var string
     */
    private $archivePathParent;

    /**
     * Absolute file name to tmp archive path including extension
     *
     * @var string
     */
    private $archiveFile;
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
    public function __construct(Filesystem $filesystem)
    {
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
    public function getArchiveFile()
    {
        return $this->archiveFile;
    }

    /**
     * Paths on server
     */
    protected function setPaths()
    {
        $this->archivePathParent = $this->filesystem->getTmpFolder();
        $this->archivePath = $this->archivePathParent . '/' . $this->archiveNameNoExtension();

        $this->filesystem->createFolder($this->archivePath);

        $this->archiveFile = $this->archivePathParent . '.zip';
    }

    /**
     * Copy our repo to a temp file
     */
    protected function copyToTempFolder()
    {
        // no initial mirroring is needed
        // all puppet modules are copy via $moduleSource adding mechanism
        // only the puppet modules folder itself has to be created here
        $this->filesystem->createFolder($this->archivePath . '/modules');

        // copy all optional sources
        foreach ($this->moduleSources as $moduleName => $moduleSource) {
            // this copies the module into the clone of the original source
            // which must contain a "modules" folder
            $this->copySource($moduleSource, $this->archivePath . '/modules/' . $moduleName);
        }
    }

    /**
     * Removes and replaces all files from vagrant-puppet-lamp which may confuse the user
     * and does not belong directly to the custom vagrant/puppet environment
     */
    protected function cleanupFiles()
    {
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
        $this->filesystem->putContents($this->archivePath . '/' . $path, $file);
    }

    /**
     * Create a zip archive
     */
    protected function zipFolder()
    {
        $this->filesystem->createArchive($this->archiveFile, $this->archivePathParent);
        // we only need the archive, not the contents of the tmp folder
        // the folder could be deleted now
        $this->filesystem->clearTmpDirectory($this->archivePathParent);
    }

    protected function archiveNameNoExtension()
    {
        return pathinfo($this->name, PATHINFO_FILENAME);
    }
}
