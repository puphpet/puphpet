<?php

namespace Puphpet\Tests\Domain\Configuration\File;

use Puphpet\Domain\Configurator\File\ConfiguratorHandler;

class ConfiguratorHandlerTest extends \PHPUnit_Framework_TestCase
{
    public function testConfigureCallsSupportedConfigurators()
    {
        $configuration = [
            'foo' => 'bar',
            'hello' => 'world'
        ];

        $domainFile = $this->getMockBuilder('Puphpet\Domain\File')
            ->disableOriginalConstructor()
            ->setMethods(array())
            ->getMock();

        $unsupportedModule = $this->getMockBuilder('Puphpet\Domain\Configurator\File\ConfiguratorInterface')
            ->setMethods(array('supports', 'configure'))
            ->getMock();

        $unsupportedModule->expects($this->once())
            ->method('supports')
            ->with($configuration)
            ->will($this->returnValue(false));

        $unsupportedModule->expects($this->never())
            ->method('configure');

        $supportedModule = $this->getMockBuilder('Puphpet\Domain\Configurator\File\ConfiguratorInterface')
            ->setMethods(array('supports', 'configure'))
            ->getMock();

        $supportedModule->expects($this->once())
            ->method('supports')
            ->with($configuration)
            ->will($this->returnValue(true));

        $supportedModule->expects($this->once())
            ->method('configure')
            ->with($domainFile, $configuration);

        $configurationModules = [$unsupportedModule, $supportedModule];

        $configurationHandler = new ConfiguratorHandler($configurationModules);
        $configurationHandler->configure($domainFile, $configuration);
    }
}
