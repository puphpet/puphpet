<?php

namespace Puphpet\Domain\Configuration;

use Puphpet\Domain\Configuration\Configuration;
use Puphpet\Domain\Filesystem;

class ConfigurationBuilder
{
    /*
     * @var string
     */
    private $bashAliasFile;

    /**
     * @var Filesystem
     */
    private $filesystem;

    /**
     * @param string $bashAliasFile absolute path to bashalias file
     * @param Filesystem $filesystem
     */
    public function __construct($bashAliasFile, Filesystem $filesystem)
    {
        $this->bashAliasFile = $bashAliasFile;
        $this->filesystem = $filesystem;
    }

    /**
     * @param array $conf
     * @return Configuration
     */
    public function build(array $conf)
    {
        $conf['server']['bashaliases'] = $this->filesystem->getContents($this->bashAliasFile);

        return new Configuration($conf);
    }
}
