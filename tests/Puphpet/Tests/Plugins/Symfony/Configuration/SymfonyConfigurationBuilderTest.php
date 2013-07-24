<?php

namespace Puphpet\Tests\Domain;

use Puphpet\Plugins\Symfony\Configuration\SymfonyConfigurationBuilder;

class SymfonyConfigurationBuilderTest extends \PHPUnit_Framework_TestCase
{
    public function testBuild()
    {
        $bashAliasFilePath = '/absolute/path';
        $bashAliasFileContent = 'content';

        $filesystem = $this->getMockBuilder('Puphpet\Domain\Filesystem')
            ->disableOriginalConstructor()
            ->setMethods(['getContents'])
            ->getMock();

        $filesystem->expects($this->once())
            ->method('getContents')
            ->with($bashAliasFilePath)
            ->will($this->returnValue($bashAliasFileContent));

        $edition = $this->getMockBuilder('Puphpet\Domain\Configuration\Edition')
            ->disableOriginalConstructor()
            ->setMethods(['getName', 'get', 'set'])
            ->getMock();

        $edition->expects($this->atLeastOnce())
            ->method('getName')
            ->will($this->returnValue('symfony'));

        $customConfiguration = [
            'project'   => [
                'name'             => 'foo.bar.dev',
                'document_root'    => '/var/www/foo.bar.dev',
                'generate_project' => true,
                'symfony_version'  => '2.3.1'
            ],
            'provider'  => [
                'local' => array(),
            ],
            'php'       => [
                'version' => 'php54'
            ],
            'webserver' => 'nginx',
            'database'  => 'mysql',
            'mysql'     => [
                'phpmyadmin' => true,
            ]
        ];

        $builder = new SymfonyConfigurationBuilder($bashAliasFilePath, $filesystem);
        $configuration = $builder->build($edition, $customConfiguration);

        $this->assertInstanceOf('\Puphpet\Domain\Configuration\Configuration', $configuration);

        $config = $configuration->toArray();
        $this->assertInternalType('array', $config);
        $this->assertArrayHasKey('provider', $config);
        $this->assertArrayHasKey('server', $config);
        $this->assertArrayHasKey('php', $config);
        $this->assertArrayHasKey('webserver', $config);
        $this->assertArrayHasKey('database', $config);

        $this->assertArrayHasKey('project', $config);
        $this->assertEquals('/var/www', $config['project']['document_root_parent']);
        $this->assertEquals('foo.bar.dev', $config['project']['name']);

        $this->assertEquals($bashAliasFileContent, $config['server']['bashaliases']);
    }
}
