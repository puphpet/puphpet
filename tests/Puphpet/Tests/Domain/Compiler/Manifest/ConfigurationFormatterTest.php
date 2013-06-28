<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\Compiler\Manifest\ConfigurationFormatter;

class ConfigurationFormatterTest extends \PHPUnit_Framework_TestCase
{
    /**
     * @expectedException \InvalidArgumentException
     */
    public function testFormatThrowsExceptionWhenConfigurationNotBound()
    {
        $formatter = new ConfigurationFormatter($this->getManifestFormatterMock());
        $formatter->format();
    }

    /**
     * @dataProvider provideFormat
     */
    public function testFormat($requestedWebserver, $validatedWebserver, $webserverConfiguration)
    {
        // mocking the request
        $configuration = $this->getMockBuilder('\Puphpet\Domain\Configuration\Configuration')
          ->disableOriginalConstructor()
          ->setMethods(['get'])
          ->getMock();

        // order:
        // server, project, mysql|postgresql, mysql, php, webserver, nginx|apache
        $configuration->expects($this->at(0))
          ->method('get')
          ->with('server')
          ->will($this->returnValue('serverConfiguration'));
        $configuration->expects($this->at(1))
          ->method('get')
          ->with('project')
          ->will($this->returnValue('projectConfiguration'));
        $configuration->expects($this->at(2))
          ->method('get')
          ->with('database')
          ->will($this->returnValue('mysql'));
        $configuration->expects($this->at(3))
          ->method('get')
          ->with('mysql')
          ->will($this->returnValue('mysqlConfiguration'));
        $configuration->expects($this->at(4))
          ->method('get')
          ->with('php')
          ->will($this->returnValue('phpConfiguration'));
        $configuration->expects($this->at(5))
          ->method('get')
          ->with('webserver')
          ->will($this->returnValue($requestedWebserver));
        $configuration->expects($this->at(6))
          ->method('get')
          ->with($validatedWebserver)
          ->will($this->returnValue($webserverConfiguration));

        // mocking the manifest formatter
        $manifestFormatter = $this->getManifestFormatterMock();

        $manifestFormatter->expects($this->once())
          ->method('setServerConfiguration')
          ->with('serverConfiguration');
        $manifestFormatter->expects($this->once())
          ->method('setProjectConfiguration')
          ->with('projectConfiguration');
        $manifestFormatter->expects($this->once())
          ->method('setDatabaseConfiguration')
          ->with('mysql', 'mysqlConfiguration');
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
        $formatter = new ConfigurationFormatter($manifestFormatter);
        $formatter->bindConfiguration($configuration);
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
                  'setProjectConfiguration',
                  'setDatabaseConfiguration',
                  'setPhpConfiguration',
                  'setWebserverConfiguration',
                  'format',
              ]
          )
          ->getMock();
    }
}
