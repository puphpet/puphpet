<?php

namespace Puphpet\Tests\Domain\Compiler\Event\Listener;

use Puphpet\Domain\Configurator\File\Event\Listener\ConfiguratorListener;

class ConfiguratorListenerTest extends \PHPUnit_Framework_TestCase
{
    public function testConfigureIsNotCalledWhenUnsupportedConfigurationIsGiven()
    {
        $configuration = ['foo' => 'bar'];
        $configurator = $this->getMockForAbstractClass('Puphpet\Domain\Configurator\File\ConfiguratorInterface');
        $configurator->expects($this->once())
            ->method('supports')
            ->with($configuration)
            ->will($this->returnValue(false));
        $configurator->expects($this->never())
            ->method('configure');

        $event = $this->getMockBuilder('Puphpet\Domain\Configurator\File\Event\ConfiguratorEvent')
            ->disableOriginalConstructor()
            ->setMethods(['getConfiguration'])
            ->getMock();

        $event->expects($this->atLeastOnce())
            ->method('getConfiguration')
            ->will($this->returnValue($configuration));

        $listener = new ConfiguratorListener($configurator);
        $listener->onConfigure($event);
    }

    public function testConfigureIsCalled()
    {
        $configuration = ['foo' => 'bar'];

        $domainFile = $this->getMockBuilder('Puphpet\Domain\File')
            ->disableOriginalConstructor()
            ->setMethods(array())
            ->getMock();

        $event = $this->getMockBuilder('Puphpet\Domain\Configurator\File\Event\ConfiguratorEvent')
            ->disableOriginalConstructor()
            ->setMethods(['getConfiguration', 'getDomainFile'])
            ->getMock();

        $event->expects($this->atLeastOnce())
            ->method('getConfiguration')
            ->will($this->returnValue($configuration));

        $event->expects($this->once())
            ->method('getDomainFile')
            ->will($this->returnValue($domainFile));

        $configurator = $this->getMockForAbstractClass('Puphpet\Domain\Configurator\File\ConfiguratorInterface');
        $configurator->expects($this->once())
            ->method('supports')
            ->with($configuration)
            ->will($this->returnValue(true));
        $configurator->expects($this->once())
            ->method('configure')
            ->with($domainFile, $configuration);

        $listener = new ConfiguratorListener($configurator);
        $listener->onConfigure($event);
    }
}
