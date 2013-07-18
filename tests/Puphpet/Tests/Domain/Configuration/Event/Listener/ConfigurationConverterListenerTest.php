<?php

namespace Puphpet\Tests\Domain\Configuration;

use Puphpet\Domain\Configuration\Event\Listener\ConfigurationConverterListener;

class ConfigurationConverterListenerTest extends \PHPUnit_Framework_TestCase
{
    public function testOnFilterWillDoNothingWhenAnotherEditionIsGiven()
    {
        $event = $this->getMockBuilder('Puphpet\Domain\Configuration\Event\ConfigurationEvent')
            ->disableOriginalConstructor()
            ->setMethods(['getEditionName', 'replace'])
            ->getMock();

        $event->expects($this->once())
            ->method('getEditionName')
            ->will($this->returnValue('something'));

        $event->expects($this->never())
            ->method('replace');

        $event->expects($this->never())
            ->method('setConfiguration');

        $listener = new ConfigurationConverterListener('symfony', ['foo' => 'bar']);
        $listener->onFilter($event);
    }

    public function testOnFilterWillTriggerRenaming()
    {
        $editionName = 'symfony';

        $event = $this->getMockBuilder('Puphpet\Domain\Configuration\Event\ConfigurationEvent')
            ->disableOriginalConstructor()
            ->setMethods(['getEditionName', 'replace'])
            ->getMock();

        $event->expects($this->at(0))
            ->method('getEditionName')
            ->will($this->returnValue($editionName));

        $event->expects($this->at(1))
            ->method('replace')
            ->with('foo', 'bar');

        $event->expects($this->at(2))
            ->method('replace')
            ->with('hello', 'world');

        $listener = new ConfigurationConverterListener($editionName, ['foo' => 'bar', 'hello' => 'world']);
        $listener->onFilter($event);
    }

    public function testOnFilterAlwaysPass()
    {
        $editionName = 'something';

        $event = $this->getMockBuilder('Puphpet\Domain\Configuration\Event\ConfigurationEvent')
            ->disableOriginalConstructor()
            ->setMethods(['getEditionName', 'replace'])
            ->getMock();

        $event->expects($this->at(0))
            ->method('getEditionName')
            ->will($this->returnValue(true));

        $event->expects($this->at(1))
            ->method('replace')
            ->with('foo', 'bar');

        $listener = new ConfigurationConverterListener($editionName, ['foo' => 'bar']);
        $listener->onFilter($event);
    }
}
