<?php

namespace Puphpet\Domain;

/**
 * Filesystem helper which abstracts simple filesystem access.
 *
 * @TODO We could integrate the Symfony Filesystem component for this purpose.
 *       However this component does not support the logic we do in the
 *       "putContents" method.
 *
 */
class Filesystem
{
    /**
     * @return string
     */
    public function getSysTempDir()
    {
        return sys_get_temp_dir();
    }

    /**
     * Returns unique folder name
     *
     * @return string|bool
     */
    public function getTmpFolder()
    {
        $dir = $this->getSysTempDir();
        $prefix = uniqid();

        $tmpFile = tempnam($dir, $prefix);

        unlink($tmpFile);

        return mkdir($tmpFile, 0755) ? $tmpFile : false;
    }

    /**
     * Creates a folder
     *
     * @param string $dir Absolute path to folder
     *
     * @return bool
     */
    public function createFolder($dir)
    {
        return mkdir($dir, 0755) ? true : false;
    }

    /**
     * Executes the given command
     *
     * @param string $cmd   a shell command
     * @param string $inDir the folder the command should be executed in
     */
    protected function exec($cmd, $inDir = '')
    {
        if ($inDir) {
            $cmd = sprintf('cd %s && ', $inDir) . $cmd;
        }
        shell_exec($cmd);
    }

    /**
     * Puts content into given file
     *
     * @param string $filename an absolute file path
     * @param string $data     file content
     *
     * @return int The function returns the number of bytes that were written
     *             to the file, or false on failure.
     */
    public function putContents($filename, $data)
    {
        $path = pathinfo($filename, PATHINFO_DIRNAME);

        $this->exec("mkdir -p {$path}");

        return file_put_contents($filename, $data);
    }

    /**
     * Mirrors/copies content from the source folder to the target folder
     *
     * @param string $sourcePath
     * @param string $targetPath
     */
    public function mirror($sourcePath, $targetPath)
    {
        shell_exec("cp -r {$sourcePath} {$targetPath}");
    }

    /**
     * Removes a file
     *
     * @param string $filePath an absolute file path
     */
    public function remove($filePath)
    {
        unlink($filePath);
    }

    /**
     * Creates a zip archive
     *
     * @param string $archivePath an absolute path where archive should be created
     * @param string $inDir       the source folder of the content
     */
    public function createArchive($archivePath, $inDir)
    {
        $this->exec(sprintf("zip -r %s * -x */.git\*", $archivePath), $inDir);
    }

    /**
     * Clears given sys tmp directory
     *
     * @param string $directory
     *
     * @return bool
     */
    public function clearTmpDirectory($directory)
    {
        // avoiding directory traversal vulnerability
        $directory = realpath($directory);

        // sth useful given?
        if (strpos($directory, $this->getSysTempDir() !== 0)) {
            return false;
        }

        $this->exec(sprintf('rm -rf %s', $directory));
    }

    /**
     * Fetches the contents of a file
     *
     * @param string $filePath an absolute file path
     *
     * @return string the raw data of the file
     */
    public function getContents($filePath)
    {
        return file_get_contents($filePath);
    }
}
