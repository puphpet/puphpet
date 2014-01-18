<?php

namespace Puphpet\Tests\Unit\MainBundle\Extension;

use Puphpet\Tests\Unit;
use Puphpet\MainBundle\Extension\ExtensionAbstract;
use Puphpet\Extension\ServerBundle\Configure as ServerExtension;

class ExtensionServerTest extends Unit\TestExtensions
{
    /**
     * @var \PHPUnit_Framework_MockObject_MockObject|ExtensionAbstract
     */
    protected $extension;

    public function setUp()
    {
        parent::setUp();

        $this->extension = new ServerExtension($this->container);
    }

    public function testGetNameReturnsExtensionName()
    {
        $expected = 'Server Basics';

        $this->assertEquals($expected, $this->extension->getName());
    }

    public function testGetSlugReturnsExtensionSlug()
    {
        $expected = 'server';

        $this->assertEquals($expected, $this->extension->getSlug());
    }

    public function testGetSourcesReturnsAssociativeArray()
    {
        $expected = [
            'stdlib'   => ":git => 'https://github.com/puphpet/puppetlabs-stdlib.git'",
        ];

        $result = $this->extension->getSources();

        $this->assertArrayHasKey('stdlib', $result);

        $this->assertEquals($expected['stdlib'], $result['stdlib']);
    }
}
