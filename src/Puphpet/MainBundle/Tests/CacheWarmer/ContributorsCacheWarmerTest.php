<?php

namespace Puphpet\MainBundle\Tests\DependencyInjection\Compiler;

use Puphpet\MainBundle\CacheWarmer\ContributorsCacheWarmer;

class ContributorsCacheWarmerTest extends \PHPUnit_Framework_TestCase
{
    public function testWarmUp()
    {
        $cacheDir = '/foo';
        $filename = 'bar';
        $contributors = ['foo' => 'bar'];
        $serializedContributors = '{"foo":"bar"}';

        $repository = $this->getMockBuilder('\Puphpet\MainBundle\Repository\ContributorRepository')
            ->disableOriginalConstructor()
            ->setMethods(['findAll'])
            ->getMock();

        $repository->expects($this->once())
            ->method('findAll')
            ->will($this->returnValue($contributors));

        $filesystem = $this->getMockBuilder('\Puphpet\MainBundle\Filesystem\Filesystem')
            ->disableOriginalConstructor()
            ->setMethods(['dumpFile'])
            ->getMock();

        $filesystem->expects($this->once())
            ->method('dumpFile')
            ->with('/foo/bar', $serializedContributors);

        $warmer = new ContributorsCacheWarmer($repository, $filename, $filesystem);
        $warmer->warmUp($cacheDir);
    }
}
