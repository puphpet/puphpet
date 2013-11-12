<?php

namespace Puphpet\Tests\Unit\MainBundle\Extension;

use Puphpet\Tests\Unit;
use Puphpet\MainBundle\Extension\ExtensionAbstract;
use Puphpet\MainBundle\Extension\Manager;

class ManagerTest extends Unit\TestExtensions
{
    /**
     * @var \PHPUnit_Framework_MockObject_MockObject|Manager
     */
    protected $manager;

    /**
     * @param string $slug
     * @return \PHPUnit_Framework_MockObject_MockObject|ExtensionAbstract
     */
    public function getExtensionMock($slug)
    {
        $mock = $this->getMockBuilder(ExtensionAbstract::class)
            ->setConstructorArgs([$this->container])
            ->setMethods(['getSlug', 'yamlParse'])
            ->getMockForAbstractClass();

        $mock->expects($this->any())
            ->method('getSlug')
            ->will($this->returnValue($slug));

        return $mock;
    }

    public function testAddExtensionToGroupSavesToGroupArray()
    {
        $extensionApache     = $this->getExtensionMock('apache');
        $extensionNginx      = $this->getExtensionMock('nginx');
        $extensionMySQL      = $this->getExtensionMock('mysql');
        $extensionPostgreSQL = $this->getExtensionMock('postgresql');

        $manager = new Manager($this->container);

        $manager->addExtensionToGroup('webserver', $extensionApache)
            ->addExtensionToGroup('webserver', $extensionNginx)
            ->addExtensionToGroup('database', $extensionMySQL)
            ->addExtensionToGroup('database', $extensionPostgreSQL);

        $this->assertEquals('webserver', $manager->belongsToGroup('apache'));
        $this->assertEquals('webserver', $manager->belongsToGroup('nginx'));
        $this->assertEquals('database', $manager->belongsToGroup('mysql'));
        $this->assertEquals('database', $manager->belongsToGroup('postgresql'));
    }

    public function testAddExtensionSavesBySlug()
    {
        $extensionApache = $this->getExtensionMock('apache');
        $extensionPHP    = $this->getExtensionMock('php');

        $manager = new Manager($this->container);

        $manager->addExtension($extensionPHP)
            ->addExtensionToGroup('webserver', $extensionApache);

        $this->assertEquals($extensionApache, $manager->getExtensionBySlug('apache'));
        $this->assertEquals($extensionPHP, $manager->getExtensionBySlug('php'));
    }

    public function testBelongsToGroupReturnsFalseOnExtensionNotPartOfGroup()
    {
        $extensionPHP = $this->getExtensionMock('php');

        $manager = new Manager($this->container);

        $manager->addExtension($extensionPHP);

        $this->assertFalse($manager->belongsToGroup('php'));
    }
}
