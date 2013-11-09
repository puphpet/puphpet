<?php

namespace Puphpet\Tests\Unit\MainBundle\Extension;

use Puphpet\Tests\Unit;
use Puphpet\MainBundle\Extension\ExtensionAbstract;

class ExtensionAbstractTest extends Unit\TestExtensions
{
    /**
     * @var \PHPUnit_Framework_MockObject_MockObject|ExtensionAbstract
     */
    protected $extension;

    protected $availableData = [
        'available_modules' => [
            'php'  => [
                'cgi',
                'cli',
            ],
            'pear' => [
                'Authentication' => [
                    'Auth_SASL2',
                    'OpenId',
                ],
            ],
        ],
        'available_ini'     => [
            'allow_url_fopen',
            'allow_url_include',
        ],
    ];

    protected $currentData = [
        'version'  => '55',
        'composer' => '1',
        'modules'  => [
            'php'  => [],
            'pear' => [],
            'pecl' => [],
        ],
        'ini'      => [],
        'timezone' => null,
    ];

    protected $customData = [
        'version'  => '54',
        'composer' => '0',
        'ini'      => ['display_errors' => 'Off',],
        'timezone' => 'America/Chihuahua',
    ];

    protected $defaultData = [
        'modules'  => [
            'php'  => [
                'cli',
            ],
            'pecl' => [
                'pecl_http'
            ],
        ],
        'ini'      => [
            'display_errors' => 'On',
        ],
        'timezone' => 'America/Chicago',
    ];

    public function setUp()
    {
        parent::setUp();

        $this->extension = $this->getMockBuilder(ExtensionAbstract::class)
            ->setConstructorArgs([$this->container])
            ->setMethods(['yamlParse'])
            ->getMockForAbstractClass();
    }

    public function testGetNameThrowsExceptionWhenNameUndefined()
    {
        $this->setExpectedException('Exception', 'Extension name has not been defined');

        $this->extension->getName();
    }

    public function testGetSlugThrowsExceptionWhenSlugUndefined()
    {
        $this->setExpectedException('Exception', 'Extension slug has not been defined');

        $this->extension->getSlug();
    }

    public function testGetSourcesReturnsEmptyArrayWhenSourcesEmpty()
    {
        $expected = [];

        $this->assertEquals($expected, $this->extension->getSources());
    }

    /**
     * @dataProvider providerHasCustomDataReturnsExpected
     */
    public function testHasCustomDataReturnsExpected($customDataValue, $expectedResult)
    {
        $this->extension->setCustomData($customDataValue);

        $this->assertEquals($expectedResult, $this->extension->hasCustomData());
    }

    public function providerHasCustomDataReturnsExpected()
    {
        return [
            [[], false],
            [['foo', 'bar'], true]
        ];
    }

    public function testGetDataMergesDefaultValuesAndAvailableValues()
    {
        $this->extension->expects($this->at(0))
            ->method('yamlParse')
            ->with('defaults.yml')
            ->will($this->returnValue($this->defaultData));

        $this->extension->expects($this->at(1))
            ->method('yamlParse')
            ->with('available.yml')
            ->will($this->returnValue($this->availableData));

        $this->extension->expects($this->at(2))
            ->method('yamlParse')
            ->with('data.yml')
            ->will($this->returnValue($this->currentData));

        $expectedResult = [
            'available_modules' => [
                'php'  => [
                    'cgi',
                    'cli',
                ],
                'pear' => [
                    'Authentication' => [
                        'Auth_SASL2',
                        'OpenId',
                    ],
                ],
            ],
            'available_ini'     => [
                'allow_url_fopen',
                'allow_url_include',
            ],
            'version'  => '55',
            'composer' => '1',
            'modules'  => [
                'php'  => [
                    'cli',
                ],
                'pear' => [],
                'pecl' => [
                    'pecl_http'
                ],
            ],
            'ini'      => [
                'display_errors' => 'On',
            ],
            'timezone' => 'America/Chicago',
        ];

        $this->assertEquals($expectedResult, $this->extension->getData());
    }

    public function testGetDataUsesCustomData()
    {
        $this->extension->setCustomData($this->customData);

        $this->extension->expects($this->at(0))
            ->method('yamlParse')
            ->with('available.yml')
            ->will($this->returnValue($this->availableData));

        $this->extension->expects($this->at(1))
            ->method('yamlParse')
            ->with('data.yml')
            ->will($this->returnValue($this->currentData));

        $expectedResult = [
            'available_modules' => [
                'php'  => [
                    'cgi',
                    'cli',
                ],
                'pear' => [
                    'Authentication' => [
                        'Auth_SASL2',
                        'OpenId',
                    ],
                ],
            ],
            'available_ini'     => [
                'allow_url_fopen',
                'allow_url_include',
            ],
            'version'  => '54',
            'composer' => '0',
            'modules'  => [
                'php'  => [],
                'pear' => [],
                'pecl' => [],
            ],
            'ini'      => [
                'display_errors' => 'Off',
            ],
            'timezone' => 'America/Chihuahua',
        ];

        $this->assertEquals($expectedResult, $this->extension->getData());
    }

    public function testGetDataExcludesAvailableDataWhenFlagged()
    {
        $this->extension->setCustomData($this->customData)
            ->setReturnAvailableData(false);

        $this->extension->expects($this->at(0))
            ->method('yamlParse')
            ->with('data.yml')
            ->will($this->returnValue($this->currentData));

        $expectedResult = [
            'version'  => '54',
            'composer' => '0',
            'modules'  => [
                'php'  => [],
                'pear' => [],
                'pecl' => [],
            ],
            'ini'      => [
                'display_errors' => 'Off',
            ],
            'timezone' => 'America/Chihuahua',
        ];

        $this->assertEquals($expectedResult, $this->extension->getData());
    }
}
