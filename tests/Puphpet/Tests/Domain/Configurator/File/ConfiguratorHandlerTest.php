<?php

namespace Puphpet\Tests\Domain\Configuration\File;

use Puphpet\Domain\Configurator\File\ConfiguratorHandler;

class ConfiguratorHandlerTest extends \PHPUnit_Framework_TestCase
{
    public function testConfigureFiresEvent()
    {
        $configuration = [
            'foo'   => 'bar',
            'hello' => 'world'
        ];

        $domainFile = $this->getMockBuilder('Puphpet\Domain\File')
            ->disableOriginalConstructor()
            ->setMethods(array())
            ->getMock();

        $eventDispatcher = $this->buildEventDispatcher();
        $eventDispatcher->expects($this->once())
            ->method('dispatch')
            ->with('file.configuration');

        $configurationHandler = new ConfiguratorHandler($eventDispatcher);
        $configurationHandler->configure($domainFile, $configuration);
    }

    private function buildEventDispatcher()
    {
        return $this->getMockBuilder('Symfony\Component\EventDispatcher\EventDispatcherInterface')
            ->setMethods(
                [
                    'dispatch',
                    'addListener',
                    'addSubscriber',
                    'removeListener',
                    'removeSubscriber',
                    'getListeners',
                    'hasListeners'
                ]
            )
            ->getMock();
    }
}
