<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\PuppetModule\Apache;

class ApacheTest extends \PHPUnit_Framework_TestCase
{
    protected $apacheArray = array();

    public function setUp()
    {
        $this->apacheArray = [
            'modules' => [
                'rewrite',
                'asis',
                'expires',
                'ssl',
            ],
            'vhosts'  => [
                [
                    'servername'    => 'awesome.dev',
                    'serveraliases' => 'www.awesome.dev,test.awesome.dev',
                    'docroot'       => '/var/www/awesome',
                    'port'          => 80,
                    'envvars'       => 'IS_AWESOME yes,IS_FINISHED no',
                ],
                [
                    'servername'    => 'puphpet.dev',
                    'serveraliases' => 'ssl.puphpet.dev,foo.puphpet.dev',
                    'docroot'       => '/var/www/puphpet.dev',
                    'port'          => 80,
                    'envvars'       => 'OPEN_SOURCED yes,CONTRIBUTE please',
                ],
                [
                    'servername'    => 'github.dev',
                    'serveraliases' => 'bam.github.dev,baz.github.dev',
                    'docroot'       => '/var/www/github',
                    'port'          => 443,
                ],
            ],
        ];
    }

    /**
     * @dataProvider providerGetFormattedReturnsEmptyArrayWhenApachePropertyEmpty
     */
    public function testGetFormattedReturnsEmptyArrayWhenApachePropertyEmpty($param)
    {
        $apache = new Apache($param);

        $expected = array();

        $this->assertEquals(
            $expected,
            $apache->getFormatted()
        );
    }

    public function providerGetFormattedReturnsEmptyArrayWhenApachePropertyEmpty()
    {
        return [
            [array()],
            [0],
            [''],
        ];
    }

    public function testGetFormattedReturnsFormattedProperties()
    {
        $this->apacheArray['vhosts'][1]['envvars']       = 'OPEN_SOURCED yes, ';
        $this->apacheArray['vhosts'][2]['serveraliases'] = array();

        $apache = new Apache($this->apacheArray);

        $expected = $this->apacheArray;

        $expected['vhosts'][0]['serveraliases'] = [
            'www.awesome.dev',
            'test.awesome.dev',
        ];
        $expected['vhosts'][0]['envvars'] = [
            'IS_AWESOME yes',
            'IS_FINISHED no',
        ];

        $expected['vhosts'][1]['serveraliases'] = [
            'ssl.puphpet.dev',
            'foo.puphpet.dev',
        ];
        $expected['vhosts'][1]['envvars'] = [
            'OPEN_SOURCED yes',
        ];

        $expected['vhosts'][2]['serveraliases'] = array();
        $expected['vhosts'][2]['envvars']       = array();

        $this->assertEquals(
            $expected,
            $apache->getFormatted()
        );
    }

    public function testGetFormattedReturnsEmptyStructuredArrayWhenVhostsEmpty()
    {
        unset($this->apacheArray['vhosts']);

        $apache = new Apache($this->apacheArray);

        $expected = [
            'modules' => [
                'rewrite',
                'asis',
                'expires',
                'ssl',
            ],
            'vhosts'  => array()
        ];

        $this->assertEquals(
            $expected,
            $apache->getFormatted()
        );
    }
}
