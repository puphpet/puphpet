<?php

namespace Puphpet\Tests\Domain\Configuration\File\Module;

use Puphpet\Domain\Configurator\File\Module\PostgreSQLConfigurator;

class PostgreSQLConfiguratorTest extends \PHPUnit_Framework_TestCase
{
    private $vendorPath = '/foo/bar';

    /**
     * @dataProvider provideUnsupported
     */
    public function testSupportReturnsFalseWithUnsupportedConfiguration($configuration)
    {
        $configurator = new PostgreSQLConfigurator($this->vendorPath);
        $this->assertFalse($configurator->supports($configuration));
    }

    static public function provideUnsupported()
    {
        return [
            [['foo' => 'bar']],
            [array()],
            [['database' => 'postgresql']],
            [['database' => 'postgresql', 'postgresql' => 'foo']],
            [['database' => 'postgresql', 'postgresql' => null]],
        ];
    }

    /**
     * @dataProvider provideSupported
     */
    public function testSupportReturnsTrueWithSupportedConfiguration($configuration)
    {
        $configurator = new PostgreSQLConfigurator($this->vendorPath);
        $this->assertTrue($configurator->supports($configuration));
    }

    static public function provideSupported()
    {
        return [
            [['database' => 'postgresql', 'postgresql' => array()]],
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
            ->with('postgresql', $this->vendorPath . '/puppetlabs/postgresql');

        $configurator = new PostgreSQLConfigurator($this->vendorPath);
        $configurator->configure($domainFile, $configuration);
    }
}
