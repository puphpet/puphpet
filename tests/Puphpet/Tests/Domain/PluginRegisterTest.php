<?php

namespace Puphpet\Tests\Domain;

use Puphpet\Tests;
use Puphpet\Plugin;
use Puphpet\Domain\PluginHandler;
use Puphpet\Domain\PluginRegister;

use \Pimple;

class PluginRegisterTest extends Tests\Base
{
    public function testRegisterCreatesEntryInContainer()
    {
        $pluginName = 'foobar';

        $plugin = $this->getMockBuilder('Puphpet\Domain\PluginInterface')
            ->getMockForAbstractClass();

        $plugin->expects($this->once())
            ->method('getName')
            ->will($this->returnValue($pluginName));

        $bucket = new Pimple;

        $pluginRegister = new PluginRegister($bucket);
        $pluginRegister->register($plugin);

        $this->assertInstanceOf('Puphpet\Domain\PluginInterface', $bucket[$pluginName]);
    }
}
