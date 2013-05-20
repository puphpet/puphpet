<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\PuppetModule\Nginx;
use Puphpet\Tests\Base;

class NginxTest extends Base
{
    protected $formatter = array();

    public function setUp()
    {
        $this->configuration = [
            'vhosts'  => [
                [
                    'servername'    => 'awesome.dev',
                    'serveraliases' => 'www.awesome.dev,test.awesome.dev',
                    'docroot'       => '/var/www/awesome',
                    'port'          => 80,
                    'envvars'       => 'IS_AWESOME yes,IS_FINISHED no',
                    'index_files'   => 'index.html,index.htm,index.php'
                ],
                [
                    'servername'    => 'puphpet.dev',
                    'serveraliases' => 'ssl.puphpet.dev,foo.puphpet.dev',
                    'docroot'       => '/var/www/puphpet.dev',
                    'port'          => 80,
                    'envvars'       => 'OPEN_SOURCED yes,CONTRIBUTE please',
                    'index_files'   => 'index.html,index.htm , index.php'
                ],
                [
                    'servername'    => 'github.dev',
                    'serveraliases' => 'bam.github.dev,baz.github.dev',
                    'docroot'       => '/var/www/github',
                    'port'          => 443,
                    'index_files'   => 'index.html '
                ],
            ],
        ];
    }

    /**
     * @dataProvider providerGetFormattedReturnsEmptyArrayWhenNginxPropertyEmpty
     */
    public function testGetFormattedReturnsEmptyArrayWhenNginxPropertyEmpty($param)
    {
        $formatter = new Nginx($param);

        $expected = array();

        $this->assertEquals(
            $expected,
            $formatter->getFormatted()
        );
    }

    public function providerGetFormattedReturnsEmptyArrayWhenNginxPropertyEmpty()
    {
        return [
            [array()],
            [0],
            [''],
        ];
    }

    /**
     * @dataProvider providerTestFormatCommonFiguration
     */
    public function testFormatCommonConfiguration($configuration)
    {
        $formatter = new Nginx(array('servername' => 'foo.bar'));
        $formatted = $formatter->getFormatted();

        $expected = array(
            'servername' => 'foo.bar',
            'vhosts'     => array(),
        );

        $this->assertEquals($expected, $formatted);
    }

    public function providerTestFormatCommonFiguration()
    {
        return [
            array('servername' => 'foo.bar'),
            array('servername' => 'foo.bar '),
            array('servername' => ' foo.bar'),
            array('servername' => ' foo.bar '),
        ];
    }

    /**
     * @group debug
     */
    public function testGetFormattedReturnsFormattedProperties()
    {
        $this->configuration['vhosts'][1]['envvars']       = 'OPEN_SOURCED yes, ';
        $this->configuration['vhosts'][2]['serveraliases'] = array();

        $formatter = new Nginx($this->configuration);

        $expected = $this->configuration;

        $expected['vhosts'][0]['serveraliases'] = [
            'www.awesome.dev',
            'test.awesome.dev',
        ];
        $expected['vhosts'][0]['envvars'] = [
            'IS_AWESOME' => 'yes',
            'IS_FINISHED' => 'no',
        ];
        $expected['vhosts'][0]['index_files'] = [
            'index.html',
            'index.htm',
            'index.php',
        ];

        $expected['vhosts'][1]['serveraliases'] = [
            'ssl.puphpet.dev',
            'foo.puphpet.dev',
        ];
        $expected['vhosts'][1]['envvars'] = [
            'OPEN_SOURCED' => 'yes',
        ];
        $expected['vhosts'][1]['index_files'] = [
            'index.html',
            'index.htm',
            'index.php',
        ];

        $expected['vhosts'][2]['serveraliases'] = array();
        $expected['vhosts'][2]['envvars']       = array();
        $expected['vhosts'][2]['index_files'] = [
            'index.html',
        ];
        $this->assertEquals(
            $expected,
            $formatter->getFormatted()
        );
    }

    public function testGetFormattedReturnsEmptyStructuredArrayWhenVhostsEmpty()
    {
        unset($this->configuration['vhosts']);

        // add some "additional" options which
        // will be ignored from the formatter
        $this->configuration['foo'] = 'bar';

        $formatter = new Nginx($this->configuration);

        $expected = [
            'vhosts'  => array(),
            'foo'     => 'bar',
        ];

        $this->assertEquals(
            $expected,
            $formatter->getFormatted()
        );
    }
}
