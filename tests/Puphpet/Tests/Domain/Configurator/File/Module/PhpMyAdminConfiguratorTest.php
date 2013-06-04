<?php

namespace Puphpet\Tests\Domain\Configuration\File\Module;

use Puphpet\Domain\Configurator\File\Module\PhpMyAdminConfigurator;

class PhpMyAdminConfiguratorTest extends \PHPUnit_Framework_TestCase
{
    private $vendorPath = '/foo/bar';

    /**
     * @dataProvider provideUnsupported
     */
    public function testSupportReturnsFalseWithUnsupportedConfiguration($configuration)
    {
        $configurator = new PhpMyAdminConfigurator($this->vendorPath);
        $this->assertFalse($configurator->supports($configuration));
    }

    static public function provideUnsupported()
    {
        return [
            [['foo' => 'bar']],
            [array()],
            [['mysql' => array()]],
            [['mysql' => ['phpmyadmin' => false]]],
            [['mysql' => ['phpmyadmin' => 0]]],
            [['mysql' => ['phpmyadmin' => '']]],
        ];
    }

    /**
     * @dataProvider provideSupported
     */
    public function testSupportReturnsTrueWithSupportedConfiguration($configuration)
    {
        $configurator = new PhpMyAdminConfigurator($this->vendorPath);
        $this->assertTrue($configurator->supports($configuration));
    }

    static public function provideSupported()
    {
        return [
            [['mysql' => ['phpmyadmin' => true]]],
        ];
    }

    public function testConfigure()
    {
        // configuration is currently not yet needed within the configurator
        // so we can assign whatever we want
        $configuration = ['foo' => 'bar'];

        $domainFile = $this->getMockBuilder('Puphpet\Domain\File')
            ->disableOriginalConstructor()
            ->setMethods(array('addModuleSource'))
            ->getMock();

        $domainFile->expects($this->once())
            ->method('addModuleSource')
            ->with('phpmyadmin', $this->vendorPath . '/frastel/puppet-phpmyadmin');

        $configurator = new PhpMyAdminConfigurator($this->vendorPath);
        $configurator->configure($domainFile, $configuration);
    }
}
