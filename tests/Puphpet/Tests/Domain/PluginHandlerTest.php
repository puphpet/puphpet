<?php

namespace Puphpet\Tests\Domain;

use Puphpet\Tests;
use Puphpet\Domain\PluginHandler;
use Puphpet\Plugin;

use \Pimple;

class PluginHandlerTest extends Tests\Base
{
    public function testCheckPluginExistsThrowsExceptionOnPluginNotFound()
    {
        $pluginName = ucfirst('fakefooplugin');
        $pluginClass = "\\Puphpet\\Plugin\\{$pluginName}\\Register";

        $this->setExpectedException(
            'Exception',
            "Plugin {$pluginClass} does not exist"
        );

        $bucket = new Pimple;

        $data = [
            $pluginName => []
        ];

        $pluginRegister = $this->getMockBuilder('Puphpet\Domain\PluginRegister')
            ->setConstructorArgs([$bucket])
            ->getMock();

        $pluginHandler = new PluginHandler($pluginRegister);
        $pluginHandler->setData($data)
            ->process();
    }

    public function testCheckPluginExistsSuccessfullyRegistersExistingPlugin()
    {
        $pluginName = ucfirst('vagrantfile');

        $data = [
            $pluginName => []
        ];

        $bucket = new Pimple;

        $pluginRegister = $this->getMockBuilder('Puphpet\Domain\PluginRegister')
            ->setConstructorArgs([$bucket])
            ->setMethods(['register'])
            ->getMock();

        $pluginClass = new Plugin\Vagrantfile\Register($data[$pluginName]);

        $pluginRegister->expects($this->once())
            ->method('register')
            ->with($pluginClass);

        $pluginHandler = new PluginHandler($pluginRegister);
        $pluginHandler->setData($data)
            ->process();
    }
}
