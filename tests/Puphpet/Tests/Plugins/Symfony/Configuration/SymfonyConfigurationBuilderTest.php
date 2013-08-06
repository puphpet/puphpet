<?php

namespace Puphpet\Tests\Domain;

use Puphpet\Plugins\Symfony\Configuration\SymfonyConfigurationBuilder;

class SymfonyConfigurationBuilderTest extends \PHPUnit_Framework_TestCase
{
    public function testBuild()
    {
        $bashAliasFilePath = '/absolute/path';
        $bashAliasFileContent = 'content';
        $boxUrl = 'http://files.vagrantup.com/precise64.box';
        $boxName = 'precise64';

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

        $edition->expects($this->at(0))
            ->method('getName')
            ->will($this->returnValue('symfony'));

        $edition->expects($this->at(1))
            ->method('get')
            ->with('[provider][type]')
            ->will($this->returnValue('local'));

        $edition->expects($this->at(2))
            ->method('get')
            ->with('box')
            ->will(
                $this->returnValue(
                    [
                        'url' => $boxUrl,
                    ]
                )
            );

        $edition->expects($this->at(3))
            ->method('get')
            ->with('provider')
            ->will(
                $this->returnValue(
                    [
                        'type'  => 'local',
                        'os'    => 'ubuntu',
                        'local' => [
                            'foldertype' => 'default',
                            'name'       => $boxName,
                        ],
                    ]
                )
            );

        $edition->expects($this->at(4))
            ->method('get')
            ->with('server')
            ->will($this->returnValue([]));


        $customConfiguration = [
            'project'   => [
                'name'             => 'foo.bar.dev',
                'document_root'    => '/var/www/foo.bar.dev',
                'generate_project' => true,
                'symfony_version'  => '2.3.1'
            ],
            'provider'  => [
                'local' => [
                    'foldertype' => 'nfs',
                ],
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
        $this->assertEquals('nfs', $config['provider']['local']['foldertype']);

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
