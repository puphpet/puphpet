<?php

namespace Puphpet\Tests\Domain\Configuration\File\Module;

use Puphpet\Domain\Configurator\File\Module\NginxConfigurator;

class NginxConfiguratorTest extends \PHPUnit_Framework_TestCase
{
    private $vendorPath = '/foo/bar';

    /**
     * @dataProvider provideUnsupported
     */
    public function testSupportReturnsFalseWithUnsupportedConfiguration($configuration)
    {
        $configurator = new NginxConfigurator($this->vendorPath);
        $this->assertFalse($configurator->supports($configuration));
    }

    static public function provideUnsupported()
    {
        return [
            [['foo' => 'bar']],
            [array()],
            [['webserver' => 'nginx']],
            [['webserver' => 'nginx', 'nginx' => 'foo']],
            [['webserver' => 'nginx', 'nginx' => null]],
        ];
    }

    /**
     * @dataProvider provideSupported
     */
    public function testSupportReturnsTrueWithSupportedConfiguration($configuration)
    {
        $configurator = new NginxConfigurator($this->vendorPath);
        $this->assertTrue($configurator->supports($configuration));
    }

    static public function provideSupported()
    {
        return [
            [['webserver' => 'nginx', 'nginx' => array()]],
        ];
    }

    public function testConfigure()
    {
        // configuration is currently not yet needed within the configurator
        // so we can assign whatever we want
        $configuration = ['foo' => 'bar'];

        $domainFile = $this->getMockBuilder('Puphpet\Domain\File')
            ->disableOriginalConstructor()
            ->setMethods(['addModuleSource'])
            ->getMock();

        $domainFile->expects($this->once())
            ->method('addModuleSource')
            ->with('nginx', $this->vendorPath . '/jfryman/puppet-nginx');

        $configurator = new NginxConfigurator($this->vendorPath);
        $configurator->configure($domainFile, $configuration);
    }
}
