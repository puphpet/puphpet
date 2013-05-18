<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\PuppetModule\PHP;
use Puphpet\Tests\Base;

class PHPTest extends Base
{
    protected $phpArray = array();

    public function setUp()
    {
        $this->phpArray = [
            'php54'    => 1,
            'pear'     => 1,
            'xdebug'   => 1,
            'composer' => 1,
            'modules'  => [
                'php'  => [
                    'php5-cli',
                    'php5-curl',
                    'php5-intl',
                    'php5-mcrypt',
                ],
                'pear' => [
                    'Auth_SASL2',
                    'OpenID',
                ],
                'pecl' => [
                    'courierauth',
                    'krb5',
                    'radius',
                ],
            ],
        ];
    }

    /**
     * @dataProvider providerGetFormattedReturnsEmptyArrayWhenPhpPropertyEmpty
     */
    public function testGetFormattedReturnsEmptyArrayWhenPhpPropertyEmpty($param)
    {
        $php = new PHP($param);

        $expected = array();

        $this->assertEquals(
            $expected,
            $php->getFormatted()
        );
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

        $php = new PHP($this->phpArray);

        $this->assertEquals(
            $expected,
            $php->getFormatted()
        );
    }

    public function providerGetFormattedReturnsEmptyArrayWhenModuleValueFalse()
    {
        return [
            ['php'],
            ['pear'],
            ['pecl'],
        ];
    }
}
