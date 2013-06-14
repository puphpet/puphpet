<?php

namespace Puphpet\Tests\Domain\File;

use Puphpet\Domain\File\ConfigurationGenerator;
use Puphpet\Domain\File\RequestGenerator;

class ConfigurationGeneratorTest extends \PHPUnit_Framework_TestCase
{
    public function testGenerateArchive()
    {
        $manifestConfiguration = ['foo' => 'bar', 'mysql' => 'here'];
        $boxConfiguration = ['box' => ['name' => 'baz']];
        $vagrantConfiguration = ['box' => ['name' => 'baz'], 'mysql' => 'here'];

        // mocking the request
        $configuration = $this->getMockBuilder('\Puphpet\Domain\Configuration\Configuration')
            ->disableOriginalConstructor()
            ->setMethods(['get'])
            ->getMock();

        $configuration->expects($this->at(0))
            ->method('get')
            ->with('box')
            ->will($this->returnValue(['name' => 'baz']));


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
            ->with($boxConfiguration, $manifestConfiguration, $vagrantConfiguration);

        $requestGenerator = new ConfigurationGenerator($generator, $requestFormatter);
        $requestGenerator->generateArchive($configuration);
    }
}
