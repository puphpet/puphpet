<?php

namespace Puphpet\MainBundle\Extension;

class Archive
{
    /**
     * @var string Location of existing, empty files
     */
    protected $sourceDir;

    /**
     * @var string Directory to save generated archive file
     */
    protected $targetDir;

    /**
     * @var array Hold associative values of filename => content
     */
    protected $filesToWrite = [];

    public function __construct()
    {
        $this->initialize();
    }

    public function getSourceDir()
    {
        if (!$this->sourceDir) {
            $this->sourceDir = __DIR__ . '/../Resources/views/manifest';
        }

        return $this->sourceDir;
    }

    public function getTargetDir()
    {
        if (!$this->targetDir) {
            $this->targetDir = $this->tempDirName();
        }

        return $this->targetDir;
    }

    public function getFilesToWrite()
    {
        return $this->filesToWrite;
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
            $this->file_put_contents(
                $this->targetDir . '/' . $file,
                $content,
                FILE_APPEND | LOCK_EX
            );
        }
    }

    /**
     * Adds a folder to archive
     *
     * @param string $folder Source folder
     * @param string $path   Path within archive
     * @return $this
     */
    public function addFolder($folder, $path)
    {
        $parentPath = dirname($this->getTargetDir() . '/'. $path);

        if (!is_dir($parentPath)) {
            mkdir($parentPath, 0775, true);
        }

        $this->exec(sprintf(
            'cp -r "%s" "%s"',
            $folder,
            $this->getTargetDir() . '/'. $path
        ));

        return $this;
    }

    /**
     * @return string
     */
    public function zip()
    {
        $folderBits = explode('/', $this->targetDir);
        $folder = array_pop($folderBits);

        // ignore .git folders/files
        $exec = sprintf(
            'cd "%s" && cd .. && zip -r "%s" "%s" -x */.git[!a]\*',
            $this->targetDir,
            $this->targetDir . '.zip',
            $folder
        );

        $this->exec($exec);

        return $this->targetDir . '.zip';
    }

    /**
     * Copy existing directory full of semi-empty template files, to a tmp location
     */
    protected function initialize()
    {
        $this->exec(sprintf(
            'cp -r "%s" "%s"',
            $this->getSourceDir(),
            $this->getTargetDir()
        ));
    }

    /**
     * Return a unique, unused temp folder name
     *
     * @return string
     */
    protected function tempDirName()
    {
        $tempfile = tempnam(sys_get_temp_dir(), '');

        if (file_exists($tempfile)) {
            $this->unlink($tempfile);
        }

        return $tempfile;
    }

    /**
     * Mockable wrapper around exec()
     *
     * @param string $cmd
     * @return string
     */
    protected function exec($cmd)
    {
        return exec($cmd);
    }

    /**
     * Mockable wrapper around unlink()
     *
     * @param string   $file
     */
    protected function unlink($file)
    {
        unlink($file);
    }

    /**
     * @param string   $filename
     * @param mixed    $data
     * @param int      $flags
     * @return int
     */
    protected function file_put_contents($filename, $data, $flags = null)
    {
        return file_put_contents($filename, $data, $flags);
    }
}
