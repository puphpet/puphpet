<?php

namespace Puphpet\Domain;

use Puphpet\Domain;

class File extends Domain
{
    private $sysTempDir;
    private $tmpFolder;
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
     * @param array $files Files to replace in our source folder
     */
    public function createArchive(array $files)
    {
        $this->setPaths();
        $this->copyToTempFolder();

        if (!empty($files['vagrantFile'])) {
            $this->copyFile('Vagrantfile', $files['vagrantFile']);
        }

        if (!empty($files['manifest'])) {
            $this->copyFile('manifests/default.pp', $files['manifest']);
        }

        if (!empty($files['bash_aliases'])) {
            $this->copyFile('modules/puphpet/files/dot/.bash_aliases', $files['bash_aliases']);
        }

        $this->zipFolder();
    }

    /**
     * Push the created archive to user
     */
    public function downloadFile()
    {
        header('Pragma: public');
        header('Expires: 0');
        header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
        header('Last-Modified: ' . gmdate ('D, d M Y H:i:s', filemtime($this->archiveFile)) . ' GMT');
        header('Cache-Control: private', false);
        header('Content-Type: application/zip');
        header('Content-Length: ' . filesize($this->archiveFile));
        header('Content-Disposition: attachment; filename="puphpet.zip"');
        header('Content-Transfer-Encoding: binary');
        header('Connection: close');

        readfile($this->archiveFile);
    }

    /**
     * Paths on server
     */
    private function setPaths()
    {
        $this->sysTempDir  = sys_get_temp_dir();
        $this->tmpFolder   = uniqid();
        $this->archiveFile = tempnam($this->sysTempDir, uniqid()) . '.zip';
    }

    /**
     * Copy our repo to a temp file
     */
    private function copyToTempFolder()
    {
        shell_exec("cp -r {$this->source} {$this->sysTempDir}/{$this->tmpFolder}");
    }

    /**
     * Replace existing file in source folder
     *
     * @param string $path Path to file within source folder to replace
     * @param string $file Content to replace file with
     */
    private function copyFile($path, $file)
    {
        file_put_contents("{$this->sysTempDir}/{$this->tmpFolder}/{$path}", $file);
    }

    /**
     * Create a zip archive
     */
    private function zipFolder()
    {
        shell_exec("cd {$this->sysTempDir}/{$this->tmpFolder} && zip -r {$this->archiveFile} * -x */.git\*");
    }
}
