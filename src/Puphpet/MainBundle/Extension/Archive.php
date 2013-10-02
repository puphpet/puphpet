<?php

namespace Puphpet\MainBundle\Extension;

class Archive
{
    /** @var string Location of existing template file */
    private $sourceDir;
    private $targetDir;

    private $filesToWrite = [];

    public function __construct()
    {
        $this->sourceDir = __DIR__ . '/../Resources/views/manifest';

        $this->initialize();
    }

    /**
     * Queues content to write to file
     *
     * @param string $file    Full filename, relative to $targetDir
     * @param string $content Content to write to file
     * @return bool
     */
    public function queueToFile($file, $content)
    {
        if (empty($file)) {
            return false;
        }

        if (empty($this->filesToWrite[$file])) {
            $this->filesToWrite[$file] = '';
        }

        $this->filesToWrite[$file] .= $content . "\n";

        return true;
    }

    /**
     * Write queued contents to files
     */
    public function write()
    {
        foreach ($this->filesToWrite as $file => $content) {
            file_put_contents(
                $this->targetDir . '/' . $file,
                $content,
                FILE_APPEND | LOCK_EX
            );
        }
    }

    /**
     * Dumps all files written to in current request
     */
    public function dumpFiles()
    {
        foreach ($this->filesToWrite as $file => $content) {
            var_dump($this->targetDir . '/' . $file);
        }
    }

    /**
     * Copy existing directory full of semi-empty template files, to a tmp location
     */
    private function initialize()
    {
        $this->targetDir = $this->tempDirName();

        exec("cp -r {$this->sourceDir} {$this->targetDir}");
    }

    /**
     * Return a unique, unused temp folder name
     *
     * @return string
     */
    private function tempDirName()
    {
        $tempfile = tempnam(sys_get_temp_dir(), '');

        if (file_exists($tempfile)) {
            unlink($tempfile);
        }

        return $tempfile;
    }
}
