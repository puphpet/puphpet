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
     * Push the created archive to user
     *
     * @param string $name Name of file to download
     */
    public function downloadFile($name)
    {
        header('Pragma: public');
        header('Expires: 0');
        header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
        header('Last-Modified: ' . gmdate ('D, d M Y H:i:s', filemtime($this->archiveFile)) . ' GMT');
        header('Cache-Control: private', false);
        header('Content-Type: application/zip');
        header('Content-Length: ' . filesize($this->archiveFile));
        header('Content-Disposition: attachment; filename="'.$name.'.zip"');
        header('Content-Transfer-Encoding: binary');
        header('Connection: close');

        $this->readfile($this->archiveFile);
    }

    /**
     * Paths on server
     */
    protected function setPaths()
    {
        $this->sysTempDir  = sys_get_temp_dir();
        $this->tmpFolder   = uniqid();
        $this->tmpPath     = $this->sysTempDir . '/' . $this->tmpFolder;
        $this->archiveFile = tempnam($this->sysTempDir, uniqid()) . '.zip';
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
        $this->exec("cd {$this->tmpPath} && zip -r {$this->archiveFile} * -x */.git\*");
    }

    protected function exec($cmd)
    {
        shell_exec($cmd);
    }

    protected function filePutContents($filename, $data)
    {
        file_put_contents($filename, $data);
    }

    protected function readfile($file)
    {
        readfile($file);
    }
}
