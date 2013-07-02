<?php

namespace Puphpet\Tests\Domain;

use Puphpet\Plugins\Symfony\Configuration\SymfonyConfigurationBuilder;

class SymfonyConfigurationBuilderTest extends \PHPUnit_Framework_TestCase
{
    public function testBuild()
    {
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
                'generate_project' => true,
                'symfony_version'  => '2.3.1'
            ],
            'box'       => [

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

        $builder = new SymfonyConfigurationBuilder();
        $configuration = $builder->build($edition, $customConfiguration);

        $this->assertInstanceOf('\Puphpet\Domain\Configuration\Configuration', $configuration);

        $config = $configuration->toArray();
        $this->assertInternalType('array', $config);
        $this->assertArrayHasKey('project', $config);
        $this->assertArrayHasKey('box', $config);
        $this->assertArrayHasKey('server', $config);
        $this->assertArrayHasKey('php', $config);
        $this->assertArrayHasKey('webserver', $config);
        $this->assertArrayHasKey('database', $config);
    }
}
