<?php

namespace Puphpet\Tests\Domain\File;

use Puphpet\Domain\File\ConfigurationGenerator;
use Puphpet\Domain\File\RequestGenerator;

class ConfigurationGeneratorTest extends \PHPUnit_Framework_TestCase
{
    public function testGenerateArchive()
    {
        $manifestConfiguration = [
            'os'    => 'windows',
            'foo'   => 'bar',
            'mysql' => 'here'
        ];
        $vagrantConfiguration = [
            'box' => [
                'name'     => 'baz',
                'provider' => 'local',
            ],
            'mysql' => 'here'
        ];
        $boxConfiguration = [
            'box' => [
                'name'     => 'baz',
                'provider' => 'local',
            ],
        ];

        $expectedUserConfiguration = [
            'foo'   => 'bar',
            'mysql' => 'here',
            'os'    => 'windows',
            'box'   => [
                'type'  => 'local',
                'local' => [
                    'name' => 'baz'
                ],
            ],
        ];

        // mocking the request
        $configuration = $this->getMockBuilder('\Puphpet\Domain\Configuration\Configuration')
            ->disableOriginalConstructor()
            ->setMethods(['get', 'toArray'])
            ->getMock();

        $getReturn = [
            'os'    => 'windows',
            'type'  => 'local',
            'local' => [
                'name' => 'baz'
            ],
        ];
        $configuration->expects($this->at(0))
            ->method('get')
            ->with('provider')
            ->will($this->returnValue($getReturn));

        $configuration->expects($this->atLeastOnce())
            ->method('toArray')
            ->will($this->returnValue($expectedUserConfiguration));

        $requestFormatter = $this->getMockBuilder(
            'Puphpet\Domain\Compiler\Manifest\ConfigurationFormatter'
        )
            ->disableOriginalConstructor()
            ->setMethods(['bindConfiguration', 'format'])
            ->getMock();

        $requestFormatter->expects($this->once())
            ->method('bindConfiguration')
            ->with($configuration);

        $requestFormatter->expects($this->once())
            ->method('format')
            ->will($this->returnValue($manifestConfiguration));

        $generator = $this->getMockBuilder('Puphpet\Domain\File\Generator')
            ->disableOriginalConstructor()
            ->setMethods(['generateArchive'])
            ->getMock();

        $generator->expects($this->once())
            ->method('generateArchive')
            ->with($boxConfiguration, $manifestConfiguration, $vagrantConfiguration, $expectedUserConfiguration);

        $requestGenerator = new ConfigurationGenerator($generator, $requestFormatter);
        $requestGenerator->generateArchive($configuration);
    }
}
