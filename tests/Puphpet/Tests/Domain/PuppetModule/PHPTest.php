<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\PuppetModule\PHP;

class PHPTest extends \PHPUnit_Framework_TestCase
{
    protected $phpArray = array();
    protected $expectedIniListMandatory = array();
    protected $expectedIniListCustom = array();

    public function setUp()
    {
        $this->phpArray = [
            'version'  => 'php55',
            'modules'  => [
                'php'      => [
                    'php5-cli',
                    'php5-curl',
                    'php5-intl',
                    'php5-mcrypt',
                ],
                'pear'     => [
                    'installed' => 1,
                    'Auth_SASL2',
                    'OpenID',
                ],
                'pecl'     => [
                    'courierauth',
                    'krb5',
                    'radius',
                ],
                'composer' => ['installed' => 1],
                'xdebug'   => ['installed' => 1],
                'xhprof'   => ['installed' => 1],
            ],
            'inilist'  => [
                'php' => [
                    'date.timezone' => 'America/Chicago',
                ],
                'custom' => 'display_errors = On,error_reporting = 1, foo = bar',
            ],
        ];

        $this->expectedIniListMandatory = [
            'date.timezone = "America/Chicago"',
        ];

        $this->expectedIniListCustom = [
            'display_errors = On',
            'error_reporting = 1',
            'foo = "bar"'
        ];
    }

    /**
     * @dataProvider providerGetFormattedReturnsEmptyArrayWhenPhpPropertyEmpty
     */
    public function testGetFormattedReturnsEmptyArrayWhenPhpPropertyEmpty($param)
    {
        $php = new PHP($param);

        $expected = array();

        $this->assertEquals($expected, $php->getFormatted());
    }

    public function providerGetFormattedReturnsEmptyArrayWhenPhpPropertyEmpty()
    {
        return [
            [array()],
            [0],
            [''],
        ];
    }

    /**
     * @dataProvider providerGetFormattedReturnsEmptyArrayWhenModuleValueFalse
     */
    public function testGetFormattedReturnsEmptyArrayWhenModuleValueFalse($moduleType)
    {
        $expected = $this->phpArray;

        unset($this->phpArray['modules'][$moduleType]);

        $expected['modules'][$moduleType] = array();
        $expected['inilist']['php']    = $this->expectedIniListMandatory;
        $expected['inilist']['custom']    = $this->expectedIniListCustom;

        $php = new PHP($this->phpArray);

        $this->assertEquals(
            $expected,
            $php->getFormatted()
        );
    }

    public static function providerGetFormattedReturnsEmptyArrayWhenModuleValueFalse()
    {
        return [
            ['php'],
            ['pear'],
            ['pecl'],
        ];
    }

    public function testGetFormattedReturnsOnlyUniqueModules()
    {
        // duplicate 'foo' will be removed
        $fixtures = [
            'modules' => [
                'php' => ['foo', 'bar', 'baz', 'foo']
            ]
        ];

        $expected = [
            'version' => 'php55',
            'modules' => [
                'php'      => ['foo', 'bar', 'baz'],
                'pear'     => array(),
                'pecl'     => array(),
                'composer' => ['installed' => 0],
                'xhprof'   => ['installed' => 0],
                'xdebug'   => ['installed' => 0],
            ],
            'inilist' => array(),
        ];

        $php = new PHP($fixtures);
        $result = $php->getFormatted();

        $this->assertEquals($expected, $result);
    }

    public function testAddPhpModuleMovesModuleAtTheEndOfTheListByDefault()
    {
        $fixtures = [
            'modules' => [
                'php' => ['bar', 'baz']
            ],
        ];

        $expected = [
            'version' => 'php55',
            'modules' => [
                'php'      => ['bar', 'baz', 'foo'],
                'pear'     => array(),
                'pecl'     => array(),
                'composer' => ['installed' => 0],
                'xhprof'   => ['installed' => 0],
                'xdebug'   => ['installed' => 0],
            ],
            'inilist' => array(),
        ];

        $php = new PHP($fixtures);
        $php->addPhpModule('foo');
        $result = $php->getFormatted();

        $this->assertEquals($expected, $result);
    }

    public function testAddPhpModuleMovesModuleAtTheBeginningOfTheList()
    {
        $fixtures = [
            'modules' => [
                'php' => ['bar', 'baz']
            ]
        ];

        $expected = [
            'version' => 'php55',
            'modules' => [
                'php'      => ['foo', 'bar', 'baz'],
                'pear'     => array(),
                'pecl'     => array(),
                'composer' => ['installed' => 0],
                'xhprof'   => ['installed' => 0],
                'xdebug'   => ['installed' => 0],
            ],
            'inilist' => array(),
        ];

        $php = new PHP($fixtures);
        $php->addPhpModule('foo', true);
        $result = $php->getFormatted();

        $this->assertEquals($expected, $result);
    }

    /**
     * @dataProvider providerForIncompleteModuleConfiguration
     */
    public function testAddPhpModuleWorksEvenWhenIncomingConfigurationIsIncomplete($fixtures)
    {
        $expected = [
            'version' => 'php55',
            'modules' => [
                'php'      => ['foo'],
                'pear'     => array(),
                'pecl'     => array(),
                'composer' => ['installed' => 0],
                'xhprof'   => ['installed' => 0],
                'xdebug'   => ['installed' => 0],
            ],
            'inilist' => array(),
        ];

        $php = new PHP($fixtures);
        $php->addPhpModule('foo', true);
        $result = $php->getFormatted();

        $this->assertEquals($expected, $result);
    }

    public static function providerForIncompleteModuleConfiguration()
    {
        return [
            [array()],
            [['modules' => array()]]
        ];
    }

    public function testFormatIniReturnsProperlyFormattedIniList()
    {
        $expected = $this->phpArray;

        $expected['inilist']['php'] = $this->expectedIniListMandatory;
        $expected['inilist']['custom'] = $this->expectedIniListCustom;

        $php = new PHP($this->phpArray);
        $result = $php->getFormatted();

        $this->assertEquals($expected, $result);
    }

    public function testFormatIniReturnsEmptyArrayWhenNoIniDirectives()
    {
        $this->phpArray['inilist'] = false;

        $expected = $this->phpArray;

        $expected['inilist'] = array();

        $php = new PHP($this->phpArray);
        $result = $php->getFormatted();

        $this->assertEquals($expected, $result);
    }
}
