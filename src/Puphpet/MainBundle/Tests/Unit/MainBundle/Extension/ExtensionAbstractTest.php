<?php

namespace Puphpet\Tests\Unit\MainBundle\Extension;

use Puphpet\Tests\Unit;
use Puphpet\MainBundle\Extension\ExtensionAbstract;

class ExtensionAbstractTest extends Unit\TestExtensions
{
    /**
     * @var \PHPUnit_Framework_MockObject_MockObject|ExtensionAbstract
     */
    protected $extension;

    public function setUp()
    {
        parent::setUp();

        $this->extension = $this->getMockBuilder(ExtensionAbstract::class)
            ->setConstructorArgs([$this->container])
            ->getMockForAbstractClass();
    }

    public function testGetNameThrowsExceptionWhenNameUndefined()
    {
        $this->setExpectedException('Exception', 'Extension name has not been defined');

        $this->extension->getName();
    }

    public function testGetSlugThrowsExceptionWhenSlugUndefined()
    {
        $this->setExpectedException('Exception', 'Extension slug has not been defined');

        $this->extension->getSlug();
    }

    public function testGetSourcesReturnsEmptyArrayWhenSourcesEmpty()
    {
        $expected = [];

        $this->assertEquals($expected, $this->extension->getSources());
    }
}
