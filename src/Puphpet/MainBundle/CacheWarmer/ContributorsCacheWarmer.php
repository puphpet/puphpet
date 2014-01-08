<?php

namespace Puphpet\MainBundle\CacheWarmer;

use Puphpet\MainBundle\Filesystem\Filesystem;
use Puphpet\MainBundle\Repository\ContributorRepository;
use Symfony\Component\HttpKernel\CacheWarmer\CacheWarmerInterface;

class ContributorsCacheWarmer implements CacheWarmerInterface
{
    /**
     * @var ContributorRepository
     */
    private $repository;

    /**
     * @var string
     */
    private $filename;

    /**
     * @var Filesystem
     */
    private $filesystem;

    /**
     * @param ContributorRepository $repository
     * @param string                $filename
     * @param Filesystem            $filesystem
     */
    public function __construct(ContributorRepository $repository, $filename, Filesystem $filesystem)
    {
        $this->repository = $repository;
        $this->filename = $filename;
        $this->filesystem = $filesystem;
    }

    /**
     * Checks whether this warmer is optional or not.
     *
     * Optional warmers can be ignored on certain conditions.
     *
     * A warmer should return true if the cache can be
     * generated incrementally and on-demand.
     *
     * @return Boolean true if the warmer is optional, false otherwise
     */
    public function isOptional()
    {
        return false;
    }

    /**
     * Warms up the cache.
     *
     * @param string $cacheDir The cache directory
     */
    public function warmUp($cacheDir)
    {
        $contributors = $this->repository->findAll();

        // only cache valid content and no reponses with errors or whatever
        if (count($contributors) && !isset($contributors['message'])) {
            $this->filesystem->dumpFile($cacheDir . '/' . $this->filename, json_encode($contributors));
        }
    }
}
