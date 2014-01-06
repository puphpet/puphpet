<?php

namespace Puphpet\Tests\Unit\MainBundle\Extension;

use Puphpet\Extension\VagrantfileLocalBundle\EventListener\HostnameMixinListener;
use Puphpet\MainBundle\Event\ConfigurationEvent;

class HostnameMixinListenerTest extends \PHPUnit_Framework_TestCase
{
    /**
     * @dataProvider provideConfiguration
     */
    public function testMixin($configuration, $data, $expectedData)
    {
        $event = new ConfigurationEvent($configuration, $data);

        $listener = new HostnameMixinListener();
        $listener->onPreBind($event);

        $resultData = $event->getData();
        $this->assertEquals($expectedData, $resultData);
    }

    public function provideConfiguration()
    {
        // apache config ...
        $configuration = [
            'apache' => [
                'vhosts' => [
                    'random' => [
                        'servername' => 'apache.example.com'
                    ]
                ]
            ]
        ];

        $data = [
            'foo' => 'bar',
            'vm'  => [
                'some' => 'thing',
            ]
        ];

        $expectedData = [
            'foo' => 'bar',
            'vm'  => [
                'some'     => 'thing',
                'hostname' => 'apache.example.com'
            ]
        ];

        $apacheConfig = [$configuration, $data, $expectedData];

        // nginx config ...
        $configuration = [
            'nginx' => [
                'vhosts' => [
                    'random123' => [
                        'servername' => 'nginx.example.com'
                    ]
                ]
            ]
        ];

        $data = [
            'foo' => 'bar',
            'vm'  => [
                'some' => 'thing',
            ]
        ];

        $expectedData = [
            'foo' => 'bar',
            'vm'  => [
                'some'     => 'thing',
                'hostname' => 'nginx.example.com'
            ]
        ];
        $nginxConfig = [$configuration, $data, $expectedData];

        return [
            $apacheConfig,
            $nginxConfig,
        ];
    }
}
