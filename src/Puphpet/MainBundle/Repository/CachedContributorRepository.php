<?php

namespace Puphpet\MainBundle\Repository;

use Puphpet\MainBundle\Filesystem\Filesystem;

/**
 * Cache Proxy for ContributorRepository
 */
class CachedContributorRepository
{

    private $cacheDir;
    private $filename;

    /**
     * @var Filesystem
     */
    private $filesystem;

    /**
     * @var ContributorRepository
     */
    private $repository;

    /**
     * @param string                $cacheDir   the kernel.cache_dir
     * @param string                $filename   the cache filename
     * @param Filesystem            $filesystem
     * @param ContributorRepository $repository the repository as fallback if cache does not exist
     */
    public function __construct($cacheDir, $filename, Filesystem $filesystem, ContributorRepository $repository)
    {
        $this->cacheDir = $cacheDir;
        $this->filename = $filename;
        $this->filesystem = $filesystem;
        $this->repository = $repository;
    }

    /**
     * @return array|mixed
     */
    public function findAll()
    {
        $content = $this->getCachedContent();
        // cached content does exist? if yes, unserialize it and we are done
        if ($content) {
            return json_decode($content, true);
        }

        // oh, cache does not exist.. trigger the fallback
        return $this->repository->findAll();
    }

    /**
     * @return string
     */
    protected function getCachedContent()
    {
        return $this->filesystem->readFile($this->cacheDir . '/' . $this->filename);
    }
}
