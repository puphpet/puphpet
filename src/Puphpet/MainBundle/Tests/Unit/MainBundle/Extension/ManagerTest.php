<?php

namespace Puphpet\Tests\Unit\MainBundle\Extension;

use Puphpet\Tests\Unit;
use Puphpet\MainBundle\Extension\Manager;

use Symfony\Component\Yaml\Exception;
use Symfony\Component\Yaml\Yaml;

class ManagerTest extends Unit\BaseTest
{
    const CONF_DIR = Unit\BaseTest::BASE_TEST_DIR . '/assets/config';

    protected $configs = [
        'vagrantfile-local' => [
            'data' => [
                'target'  => '',
                'vm'      => [
                    'hostname'        => '',
                    'chosen_provider' => 'virtualbox',
                    'box'             => 'puphpet/debian75-x64',
                    'box_url'         => 'puphpet/debian75-x64',
                    'memory'          => 512,
                    'cpus'            => 1,
                    'network'         => [
                        'private_network' => '192.168.56.101',
                        'forwarded_port'  => [],
                    ]
                ],
                'vagrant' => [
                    'host' => 'detect',
                ],
            ],
            'defaults' => [
                'target' => 'local',
                'vm'      => [
                    'hostname'        => '',
                    'chosen_provider' => 'virtualbox',
                    'box'             => 'puphpet/debian75-x64',
                    'box_url'         => 'puphpet/debian75-x64',
                    'memory'          => 512,
                    'cpus'            => 1,
                    'network'         => [
                        'private_network' => '192.168.56.101',
                        'forwarded_port'  => [],
                    ]
                ],
                'vagrant' => [
                    'host' => 'detect',
                ],
            ],
            'available' => [
                'empty_synced_folder'  => [
                    'source'    => '',
                    'target'    => '',
                    'id'        => 'vagrant-root',
                    'sync_type' => 'default',
                    'owner'     => 'www-data',
                    'group'     => 'www-data',
                    'rsync'     => [
                        'args'    => [
                            '--verbose',
                            '--archive',
                            '-z',
                        ],
                        'exclude' => [
                            '.vagrant/',
                            '.git/',
                        ],
                        'auto'    => true,
                    ],
                ],
                'empty_forwarded_port' => [
                    'host'  => '',
                    'guest' => '',
                ],
                'available_data'       => [
                    'foo',
                    'bar',
                    'baz',
                ],
            ],
        ],
    ];

    protected $configsSaved = [];

    public function setUp()
    {
        $this->configsSaved = $this->configs;

        parent::setUp();
    }

    public function tearDown()
    {
        $this->configs = $this->configsSaved;

        parent::tearDown();
    }

    public function testAddExtensionThrowsExceptionOnInvalidYamlFileContents()
    {
        $this->setExpectedException(Exception\ParseException::class);

        $manager = new Manager(self::CONF_DIR);
        $manager->addExtension('extension-broken');
    }

    public function testAddExtensionConvertsExtensionNameDashToUnderscore()
    {
        $manager = new Manager(self::CONF_DIR);
        $manager->addExtension('vagrantfile-local');

        $extensionsArray = $manager->getExtensions();

        $this->assertArrayHasKey('vagrantfile_local', $extensionsArray);
        $this->assertArrayNotHasKey('vagrantfile-local', $extensionsArray);
        $this->assertCount(1, $extensionsArray);

        $extensionData = $manager->getExtension('vagrantfile-local');

        $this->assertTrue(is_array($extensionData));
    }

    public function testAddExtensionSetsDataInDefaultsAndDataKeys()
    {
        $manager = new Manager(self::CONF_DIR);
        $manager->addExtension('vagrantfile-local');

        $extOneData = $this->configs['vagrantfile-local'];

        $mergedDataAvailable = array_merge($extOneData['data'], $extOneData['available']);

        $extensionValues = $manager->getExtension('vagrantfile-local');

        $this->assertEquals($extOneData['defaults'], $extensionValues['defaults']);
        $this->assertEquals($mergedDataAvailable, $extensionValues['data']);
    }

    public function testAddExtensionMergesDataDefaultsAndAvailableData()
    {
        $manager = new Manager(self::CONF_DIR);
        $manager->addExtension('vagrantfile-local');

        $extOneData = $this->configs['vagrantfile-local'];

        $extensionValues = $manager->getExtension('vagrantfile-local');

        $dataDefaultsMerged = array_replace_recursive(
            $extOneData['data'],
            $extOneData['defaults']
        );
        $mergedData = array_merge($dataDefaultsMerged, $extOneData['available']);

        $this->assertEquals($mergedData, $extensionValues['merged']);
    }

    public function testAddExtensionHandlesMultipleExtensions()
    {
        $manager = new Manager(self::CONF_DIR);
        $manager->addExtension('vagrantfile-local');
        $manager->addExtension('php');
        $manager->addExtension('vagrantfile-rackspace');

        $extensions = $manager->getExtensions();

        $this->assertSame(3, count($extensions));
    }

    public function testSetCustomDataAllOverridesDefaultData()
    {
        $manager = new Manager(self::CONF_DIR);
        $manager->addExtension('vagrantfile-local');
        $manager->addExtension('vagrantfile-rackspace');

        $customData = Yaml::parse(self::CONF_DIR . '/custom-data/custom.yml');

        $manager->setCustomDataAll($customData);

        $expectedResult = Yaml::parse(self::CONF_DIR . '/custom-data/expected-merged.yml');

        $this->assertEquals($expectedResult, $manager->getExtensions());
    }
}
