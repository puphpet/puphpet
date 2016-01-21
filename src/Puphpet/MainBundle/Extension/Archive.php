<?php

namespace Puphpet\MainBundle\Extension;

class Archive
{
    const ARCHIVE_LOCATION = __DIR__ . '/../../../../archive';
    const ZIP_COMMAND      = 'cd "%s" && cd .. && zip -r "%s" "%s" -x "*/.git/*" -x "*/.tmp/*" -x "*/.librarian/*"';

    /**
     * @var string Location of existing, empty files
     */
    protected $sourceDir;

    /**
     * @var string Subdirectory inside $sourceDir to grab files from
     */
    protected $subDir;

    /**
     * @var string Directory to save generated archive file
     */
    protected $targetDir;

    /**
     * @var array Hold associative values of filename => content
     */
    protected $filesToWrite = [];

    public function __construct($subDir = false)
    {
        $this->subDir = $subDir;

        $this->initialize();
    }

    public function getSourceDir()
    {
        if (!$this->sourceDir) {
            $this->sourceDir = sprintf('%s/%s', self::ARCHIVE_LOCATION, $this->subDir);
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
            static::ZIP_COMMAND,
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
     * @see http://tldp.org/LDP/abs/html/exitcodes.html
     * @param string $cmd
     * @return string
     */
    protected function exec($cmd)
    {
        $ret =  exec($cmd, $out, $code);
        if (127 == $code) {
            error_log('Command not found: ' . $cmd);
        }
        return $ret;
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
