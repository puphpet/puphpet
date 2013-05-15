<?php

namespace Puphpet\Domain;

use Puphpet\Domain;

class File extends Domain
{
    private $sysTempDir;
    private $tmpFolder;
    private $source;
    private $archiveFile;

    public function __construct($source)
    {
        $this->source = $source;
    }

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

        shell_exec("cd {$this->sysTempDir}/{$this->tmpFolder} && zip -r {$this->archiveFile} * -x */.git\*");
    }

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

    private function setPaths()
    {
        $this->sysTempDir  = sys_get_temp_dir();
        $this->tmpFolder   = uniqid();
        $this->archiveFile = tempnam($this->sysTempDir, uniqid()) . '.zip';
    }

    private function copyToTempFolder()
    {
        shell_exec("cp -r {$this->source} {$this->sysTempDir}/{$this->tmpFolder}");
    }

    private function copyFile($path, $file)
    {
        file_put_contents("{$this->sysTempDir}/{$this->tmpFolder}/{$path}", $file);
    }
}
