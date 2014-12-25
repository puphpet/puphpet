<?php

namespace Puphpet\Tests\Unit\MainBundle\Extension;

use Puphpet\Tests\Unit;
use Puphpet\MainBundle\Extension\ExtensionAbstract;
use Puphpet\Extension\PackageBundle\Configure as PackageExtension;

class ExtensionServerTest extends Unit\TestExtensions
{
    /**
     * @var \PHPUnit_Framework_MockObject_MockObject|ExtensionAbstract
     */
    protected $extension;

    public function setUp()
    {
        parent::setUp();

        $this->extension = new PackageExtension($this->container);
    }

    public function testGetNameReturnsExtensionName()
    {
        $expected = 'Packages';

        $this->assertEquals($expected, $this->extension->getName());
    }

    public function testGetSlugReturnsExtensionSlug()
    {
        $expected = 'server';

        $this->assertEquals($expected, $this->extension->getSlug());
    }
}
