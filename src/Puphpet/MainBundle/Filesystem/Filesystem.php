<?php


namespace Puphpet\MainBundle\Filesystem;

use Symfony\Component\Filesystem\Filesystem as BaseFileystem;

class Filesystem extends BaseFileystem
{
    /**
     * Reads file and returns its content
     *
     * @param string $filepath
     *
     * @return string|bool
     */
    public function readFile($filepath)
    {
        return file_get_contents($filepath);
    }
}
