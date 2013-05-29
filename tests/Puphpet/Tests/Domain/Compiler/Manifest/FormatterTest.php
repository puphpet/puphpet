<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\Compiler\Manifest\Formatter;

class FormatterTest extends \PHPUnit_Framework_TestCase
{
    private $serverConfiguration = ['server_foo' => 'server_bar'];
    private $serverFormatted = ['server_hello' => 'server_world'];

    private $phpConfiguration = ['php_foo' => 'php_bar'];
    private $phpFormatted = ['php_hello' => 'php_world'];

    private $mysqlConfiguration = ['mysql_foo' => 'mysql_bar'];
    private $mysqlFormatted = ['mysql_hello' => 'mysql_world'];

    private $apacheConfiguration = ['apache_foo' => 'apache_bar'];
    private $apacheFormatted = ['apache_hello' => 'apache_world'];

    private $nginxConfiguration = ['nginx_foo' => 'nginx_bar'];
    private $nginxFormatted = ['nginx_hello' => 'nginx_world'];

    public function testFormatWithRequestedApacheConfiguration()
    {
        $webserver = 'apache';

        $expected = [
            'webserver'   => $webserver,
            'php_service' => $webserver,
            'server'      => $this->serverFormatted,
            'php'         => $this->phpFormatted,
            'mysql'       => $this->mysqlFormatted,
            'apache'      => $this->apacheFormatted,
        ];

        // server
        $serverMock = $this->getServerMock();

        // php
        $phpMock = $this->getMockBuilder('\Puphpet\Domain\PuppetModule\PHP')
          ->disableOriginalConstructor()
          ->setMethods(['setConfiguration', 'getFormatted'])
          ->getMock();

        $phpMock->expects($this->once())
          ->method('setConfiguration')
          ->with($this->phpConfiguration);

        $phpMock->expects($this->once())
          ->method('getFormatted')
          ->will($this->returnValue($this->phpFormatted));

        // mysql
        $mysqlMock = $this->getMysqlMock();

        // nginx
        $nginxMock = $this->getMockBuilder('\Puphpet\Domain\PuppetModule\Nginx')
          ->disableOriginalConstructor()
          ->setMethods(['setConfiguration', 'getFormatted'])
          ->getMock();

        $nginxMock->expects($this->never())
          ->method('setConfiguration');

        $nginxMock->expects($this->never())
          ->method('getFormatted');

        // apache
        $apacheMock = $this->getMockBuilder('\Puphpet\Domain\PuppetModule\Apache')
          ->disableOriginalConstructor()
          ->setMethods(['setConfiguration', 'getFormatted'])
          ->getMock();

        $apacheMock->expects($this->once())
          ->method('setConfiguration')
          ->with($this->apacheConfiguration);

        $apacheMock->expects($this->once())
          ->method('getFormatted')
          ->will($this->returnValue($this->apacheFormatted));

        $formatter = new Formatter([
            'server' => $serverMock,
            'php'    => $phpMock,
            'mysql'  => $mysqlMock,
            'nginx'  => $nginxMock,
            'apache' => $apacheMock,
        ]);
        $formatter->setServerConfiguration($this->serverConfiguration);
        $formatter->setPhpConfiguration($this->phpConfiguration);
        $formatter->setMysqlConfiguration($this->mysqlConfiguration);
        $formatter->setWebserverConfiguration($webserver, $this->apacheConfiguration);
        $result = $formatter->format();

        $this->assertArrayHasKey('server', $result);
        $this->assertArrayHasKey('php', $result);
        $this->assertArrayHasKey('mysql', $result);
        $this->assertArrayHasKey('apache', $result);
        $this->assertEquals($expected, $result);
    }

    public function testFormatWithRequestedNginxConfiguration()
    {
        $webserver = 'nginx';

        $expected = [
            'webserver'   => $webserver,
            'php_service' => 'php5-fpm',
            'server'      => $this->serverFormatted,
            'php'         => $this->phpFormatted,
            'mysql'       => $this->mysqlFormatted,
            'nginx'       => $this->nginxFormatted,
        ];

        // server
        $serverMock = $this->getServerMock();

        // php
        $phpMock = $this->getMockBuilder('\Puphpet\Domain\PuppetModule\PHP')
          ->disableOriginalConstructor()
          ->setMethods(['setConfiguration', 'getFormatted', 'addPhpModule'])
          ->getMock();

        $phpMock->expects($this->once())
          ->method('setConfiguration')
          ->with($this->phpConfiguration);

        $phpMock->expects($this->once())
          ->method('getFormatted')
          ->will($this->returnValue($this->phpFormatted));

        $phpMock->expects($this->once())
          ->method('addPhpModule')
          ->with('php5-fpm', true);

        // mysql
        $mysqlMock = $this->getMysqlMock();

        // nginx
        $nginxMock = $this->getMockBuilder('\Puphpet\Domain\PuppetModule\Nginx')
          ->disableOriginalConstructor()
          ->setMethods(['setConfiguration', 'getFormatted'])
          ->getMock();

        $nginxMock->expects($this->once())
          ->method('setConfiguration')
          ->with($this->nginxConfiguration);

        $nginxMock->expects($this->once())
          ->method('getFormatted')
          ->will($this->returnValue($this->nginxFormatted));

        // apache
        $apacheMock = $this->getMockBuilder('\Puphpet\Domain\PuppetModule\Apache')
          ->disableOriginalConstructor()
          ->setMethods(['setConfiguration', 'getFormatted'])
          ->getMock();

        $apacheMock->expects($this->never())
          ->method('setConfiguration');

        $apacheMock->expects($this->never())
          ->method('getFormatted');

        $formatter = new Formatter([
            'server' => $serverMock,
            'php'    => $phpMock,
            'mysql'  => $mysqlMock,
            'nginx'  => $nginxMock,
            'apache' => $apacheMock,
        ]);
        $formatter->setServerConfiguration($this->serverConfiguration);
        $formatter->setPhpConfiguration($this->phpConfiguration);
        $formatter->setMysqlConfiguration($this->mysqlConfiguration);
        $formatter->setWebserverConfiguration($webserver, $this->nginxConfiguration);
        $result = $formatter->format();

        $this->assertArrayHasKey('server', $result);
        $this->assertArrayHasKey('php', $result);
        $this->assertArrayHasKey('mysql', $result);
        $this->assertArrayHasKey('nginx', $result);
        $this->assertEquals($expected, $result);
    }

    /**
     * @expectedException \InvalidArgumentException
     * @expectedMessage   PuppetModule not registered for configuration
     */
    public function testFormatThrowsExceptionWhenRequestedFormatterIsNotRegistered()
    {
        $formatter = new Formatter([]);
        $formatter->setServerConfiguration(['foo' => 'bar']);
        $formatter->format();
    }

    private function getMysqlMock()
    {
        $mysqlMock = $this->getMockBuilder('\Puphpet\Domain\PuppetModule\MySQL')
          ->disableOriginalConstructor()
          ->setMethods(['setConfiguration', 'getFormatted'])
          ->getMock();

        $mysqlMock->expects($this->once())
          ->method('setConfiguration')
          ->with($this->mysqlConfiguration);

        $mysqlMock->expects($this->once())
          ->method('getFormatted')
          ->will($this->returnValue($this->mysqlFormatted));

        return $mysqlMock;
    }

    private function getServerMock()
    {
        $serverMock = $this->getMockBuilder('\Puphpet\Domain\PuppetModule\Server')
          ->disableOriginalConstructor()
          ->setMethods(['setConfiguration', 'getFormatted'])
          ->getMock();

        $serverMock->expects($this->once())
          ->method('setConfiguration')
          ->with($this->serverConfiguration);

        $serverMock->expects($this->once())
          ->method('getFormatted')
          ->will($this->returnValue($this->serverFormatted));

        return $serverMock;
    }
}
