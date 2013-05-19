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

        return $this->zipFolder();
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
        $this->exec("cp -r {$this->source} {$this->tmpPath}");
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

        return "{$this->archiveFile}.zip";
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
