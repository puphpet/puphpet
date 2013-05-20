<?php

namespace Puphpet\Domain;

use Puphpet\Domain;

class File extends Domain
{
    private $sysTempDir;
    private $tmpFolder;
    private $tmpPath;
    private $source;
    private $archiveFile;
    private $moduleSources = array();

    /**
     * @param string $source Absolute path to archive
     */
    public function __construct($source)
    {
        $this->source = $source;
    }

    /**
     * @param array $replacementFiles Files to replace in our source folder
     * @return string Path to generated file
     */
    public function createArchive(array $replacementFiles = array())
    {
        $this->setPaths();
        $this->copyToTempFolder();

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
        return "{$this->archiveFile}.zip";
    }

    /**
     * Paths on server
     */
    protected function setPaths()
    {
        $this->sysTempDir  = $this->getSysTempDir();
        $this->tmpFolder   = $this->getTmpFolder();
        $this->tmpPath     = $this->sysTempDir . '/' . $this->tmpFolder;
        $this->archiveFile = $this->getTmpFile($this->sysTempDir, $this->tmpFolder);
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
        shell_exec("cp -r {$sourcePath} {$targetPath}");
    }

    /**
     * Replace existing file in source folder
     *
     * @param string $path Path to file within source folder to replace
     * @param string $file Content to replace file with
     */
    protected function copyFile($path, $file)
    {
        $this->filePutContents("{$this->tmpPath}/{$path}", $file);
    }

    /**
     * Create a zip archive
     */
    protected function zipFolder()
    {
        $this->exec("cd {$this->tmpPath} && zip -r {$this->archiveFile}.zip * -x */.git\*");
    }

    /**
     * @return string
     */
    protected function getSysTempDir()
    {
        return sys_get_temp_dir();
    }

    protected function getTmpFolder()
    {
        return uniqid();
    }

    protected function getTmpFile($dir, $prefix)
    {
        return tempnam($dir, $prefix);
    }

    protected function exec($cmd)
    {
        shell_exec($cmd);
    }

    protected function filePutContents($filename, $data)
    {
        file_put_contents($filename, $data);
    }
}
