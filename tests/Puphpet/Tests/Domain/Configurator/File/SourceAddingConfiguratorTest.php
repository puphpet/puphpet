<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\Configurator\File\SourceAddingConfigurator;

class SourceAddingConfiguratorTest extends \PHPUnit_Framework_TestCase
{
    public function testSupportsReturnsFalse()
    {
        $configuration = ['foo'];
        $decider = $this->buildDecider();

        $decider->expects($this->once())
            ->method('supports')
            ->with($configuration)
            ->will($this->returnValue(false));

        $targetModuleName = 'foo';
        $vendorModulePath = 'vendor/bar';

        $configurator = new SourceAddingConfigurator($decider, [$targetModuleName => $vendorModulePath]);
        $this->assertFalse($configurator->supports($configuration));
    }

    public function testSupportsReturnsTrue()
    {
        $configuration = ['foo'];
        $decider = $this->buildDecider();
        $decider->expects($this->once())
            ->method('supports')
            ->with($configuration)
            ->will($this->returnValue(true));

        $targetModuleName = 'foo';
        $vendorModulePath = 'vendor/bar';

        $configurator = new SourceAddingConfigurator($decider, [$targetModuleName => $vendorModulePath]);
        $this->assertTrue($configurator->supports($configuration));
    }

    public function testConfigure()
    {
        $configuration = ['foo'];
        $decider = $this->buildDecider();

        $targetModuleName = 'foo';
        $vendorModulePath = 'vendor/bar';

        $domainFile = $this->getMockBuilder('Puphpet\Domain\File')
            ->disableOriginalConstructor()
            ->setMethods(['addModuleSource'])
            ->getMock();

        $domainFile->expects($this->once())
            ->method('addModuleSource')
            ->with($targetModuleName, $vendorModulePath);

        $configurator = new SourceAddingConfigurator($decider, [$targetModuleName => $vendorModulePath]);
        $configurator->configure($domainFile, $configuration);
    }

    private function buildDecider()
    {
        return $this->getMockForAbstractClass('Puphpet\Domain\Decider\DeciderInterface');
    }
}
