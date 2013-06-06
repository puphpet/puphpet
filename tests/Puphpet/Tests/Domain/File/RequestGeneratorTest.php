<?php

namespace Puphpet\Tests\Domain\File;

use Puphpet\Domain\File\RequestGenerator;

class RequestGeneratorTest extends \PHPUnit_Framework_TestCase
{
    public function testGenerateArchive()
    {
        $manifestConfiguration = ['foo' => 'bar', 'mysql' => 'here'];
        $boxConfiguration = ['box' => ['name' => 'baz']];
        $vagrantConfiguration = ['box' => ['name' => 'baz'], 'mysql' => 'here'];

        // mocking the request
        $parameterBag = $this->getMockBuilder('\Symfony\Component\HttpFoundation\ParameterBag')
            ->disableOriginalConstructor()
            ->setMethods(['get'])
            ->getMock();

        $parameterBag->expects($this->at(0))
            ->method('get')
            ->with('box')
            ->will($this->returnValue(['name' => 'baz']));

        $request = $this->getMockBuilder('Symfony\Component\HttpFoundation\Request')
            ->disableOriginalConstructor()
            ->setMethods(array())
            ->getMock();

        $request->request = $parameterBag;

        $requestFormatter = $this->getMockBuilder(
            'Puphpet\Domain\Compiler\Manifest\RequestFormatter'
        )
            ->disableOriginalConstructor()
            ->setMethods(['bindRequest', 'format'])
            ->getMock();

        $requestFormatter->expects($this->once())
            ->method('bindRequest')
            ->with($request);

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

        $requestGenerator = new RequestGenerator($generator, $requestFormatter);
        $requestGenerator->generateArchive($request);
    }
}
