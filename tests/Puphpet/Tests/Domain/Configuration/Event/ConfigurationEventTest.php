<?php

namespace Puphpet\Tests\Domain\Configuration\Event;

use Puphpet\Domain\Configuration\Event\ConfigurationEvent;

class ConfigurationEventTest extends \PHPUnit_Framework_TestCase
{
    public function testUnchanged()
    {
        $configuration = ['foo' => 'bar', 'hello' => 'world'];
        $event = new ConfigurationEvent('symfony', $configuration);

        $this->assertEquals($configuration, $event->getConfiguration());
    }

    public function testKnownField()
    {
        $event = new ConfigurationEvent('symfony', ['foo' => 'bar', 'hello' => 'world']);
        $event->replace('foo', '[fo][o]');

        $expectedConfiguration = ['[fo][o]' => 'bar', 'hello' => 'world'];

        $this->assertEquals($expectedConfiguration, $event->getConfiguration());
    }

    public function testUnknownField()
    {
        $configuration = ['foo' => 'bar', 'hello' => 'world'];
        $event = new ConfigurationEvent('symfony', $configuration);
        $event->replace('unknown', '[fo][o]');

        $expectedConfiguration = $configuration;
        $expectedConfiguration['[fo][o]'] = null;

        $this->assertEquals($expectedConfiguration, $event->getConfiguration());
    }
}
