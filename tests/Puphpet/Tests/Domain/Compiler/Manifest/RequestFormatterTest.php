<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\Compiler\Manifest\RequestFormatter;

class RequestFormatterTest extends \PHPUnit_Framework_TestCase
{
    /**
     * @expectedException \InvalidArgumentException
     */
    public function testFormatThrowsExceptionWhenRequestNotBound()
    {
        $formatter = new RequestFormatter($this->getManifestFormatterMock());
        $formatter->format();
    }

    /**
     * @dataProvider provideFormat
     */
    public function testFormat($requestedWebserver, $validatedWebserver, $webserverConfiguration)
    {
        // mocking the request
        $parameterBag = $this->getMockBuilder('\Symfony\Component\HttpFoundation\ParameterBag')
          ->disableOriginalConstructor()
          ->setMethods(['get'])
          ->getMock();

        // order:
        // server, mysql, php, webserver, nginx|apache
        $parameterBag->expects($this->at(0))
          ->method('get')
          ->with('server')
          ->will($this->returnValue('serverConfiguration'));
        $parameterBag->expects($this->at(1))
          ->method('get')
          ->with('mysql')
          ->will($this->returnValue('mysqlConfiguration'));
        $parameterBag->expects($this->at(2))
          ->method('get')
          ->with('php')
          ->will($this->returnValue('phpConfiguration'));
        $parameterBag->expects($this->at(3))
          ->method('get')
          ->with('webserver')
          ->will($this->returnValue($requestedWebserver));
        $parameterBag->expects($this->at(4))
          ->method('get')
          ->with($validatedWebserver)
          ->will($this->returnValue($webserverConfiguration));

        $request = $this->getMockBuilder('\Symfony\Component\HttpFoundation\Request')
          ->disableOriginalConstructor()
          ->setMethods(array())
          ->getMock();

        $request->request = $parameterBag;

        // mocking the manifest formatter
        $manifestFormatter = $this->getManifestFormatterMock();

        $manifestFormatter->expects($this->once())
          ->method('setServerConfiguration')
          ->with('serverConfiguration');
        $manifestFormatter->expects($this->once())
          ->method('setMysqlConfiguration')
          ->with('mysqlConfiguration');
        $manifestFormatter->expects($this->once())
          ->method('setPhpConfiguration')
          ->with('phpConfiguration');
        $manifestFormatter->expects($this->once())
          ->method('setWebserverConfiguration')
          ->with($validatedWebserver, $webserverConfiguration);

        $manifestFormatter->expects($this->once())
          ->method('format')
          ->will($this->returnValue('something formatted'));

        // let's go
        $formatter = new RequestFormatter($manifestFormatter);
        $formatter->bindRequest($request);
        $result = $formatter->format();

        $this->assertEquals('something formatted', $result);
    }

    public static function provideFormat()
    {
        return [
            ['apache', 'apache', 'apacheConfiguration'],
            ['nginx', 'nginx', 'nginxConfiguration'],
            ['invalid', 'apache', 'apacheConfiguration'],
        ];
    }

    private function getManifestFormatterMock()
    {
        return $this->getMockBuilder('\Puphpet\Domain\Compiler\Manifest\Formatter')
          ->disableOriginalConstructor()
          ->setMethods(
              [
                  'setServerConfiguration',
                  'setMysqlConfiguration',
                  'setPhpConfiguration',
                  'setWebserverConfiguration',
                  'format',
              ]
          )
          ->getMock();
    }
}
