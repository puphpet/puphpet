<?php

namespace Puphpet\MainBundle\Tests\DependencyInjection\Compiler;

use Puphpet\MainBundle\Repository\CachedContributorRepository;

class CachedContributorRepositoryTest extends \PHPUnit_Framework_TestCase
{

    public function testFindAllOnCacheHit()
    {
        $cacheDir = '/foo';
        $filename = 'bar';
        $serializedContributors = '{"foo":"bar"}';

        $filesystem = $this->getMockBuilder('\Puphpet\MainBundle\Filesystem\Filesystem')
            ->disableOriginalConstructor()
            ->setMethods(['readFile'])
            ->getMock();

        // simulated cache hit
        $filesystem->expects($this->once())
            ->method('readFile')
            ->with('/foo/bar')
            ->will($this->returnValue($serializedContributors));

        // callback repository should never be called
        $repository = $this->getMockBuilder('\Puphpet\MainBundle\Repository\ContributorRepository')
            ->disableOriginalConstructor()
            ->setMethods(['findAll'])
            ->getMock();

        $repository->expects($this->never())
            ->method('findAll');

        $cachedRepository = new CachedContributorRepository($cacheDir, $filename, $filesystem, $repository);
        $result = $cachedRepository->findAll();

        $this->assertEquals(['foo' => 'bar'], $result);
    }

    public function testFindAllOnCacheMiss()
    {
        $cacheDir = '/foo';
        $filename = 'bar';
        $serializedContributors = false;

        $filesystem = $this->getMockBuilder('\Puphpet\MainBundle\Filesystem\Filesystem')
            ->disableOriginalConstructor()
            ->setMethods(['readFile'])
            ->getMock();

        // simulated cache hit
        $filesystem->expects($this->once())
            ->method('readFile')
            ->with('/foo/bar')
            ->will($this->returnValue($serializedContributors));

        // callback repository should never be called
        $repository = $this->getMockBuilder('\Puphpet\MainBundle\Repository\ContributorRepository')
            ->disableOriginalConstructor()
            ->setMethods(['findAll'])
            ->getMock();

        $repository->expects($this->once())
            ->method('findAll')
            ->will($this->returnValue(['foo' => 'bar']));

        $cachedRepository = new CachedContributorRepository($cacheDir, $filename, $filesystem, $repository);
        $result = $cachedRepository->findAll();

        $this->assertEquals(['foo' => 'bar'], $result);
    }
}
