<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\PuppetModule\Server;
use Puphpet\Tests\Base;

class ServerTest extends Base
{
    protected $serverArray = array();

    public function setUp()
    {
        $this->serverArray = [
            'packages'    => 'build-essential,vim,curl',
            'bashaliases' => " super duper cool awesome bash alias\r\nwith pretty shortcuts ",
        ];
    }

    /**
     * @dataProvider providerGetFormattedReturnsEmptyArrayWhenServerPropertyEmpty
     */
    public function testGetFormattedReturnsEmptyArrayWhenServerPropertyEmpty($param)
    {
        $server = new Server($param);

        $expected = array();

        $this->assertEquals(
            $expected,
            $server->getFormatted()
        );
    }

    public function providerGetFormattedReturnsEmptyArrayWhenServerPropertyEmpty()
    {
        return [
            [array()],
            [0],
            [''],
        ];
    }

    public function testGetFormattedReturnsProperlyFormattedResult()
    {
        $expected = [
            'packages' => [
                "'build-essential'",
                "'vim'",
                "'curl'",
            ],
            'bashaliases' => "super duper cool awesome bash alias\nwith pretty shortcuts",
        ];

        $server = new Server($this->serverArray);

        $this->assertEquals(
            $expected,
            $server->getFormatted()
        );
    }

    public function testGetFormattedRemovesPythonSoftwarePropertiesFromPackages()
    {
        $this->serverArray['packages'] .= ',python-software-properties';

        $expected = [
            'packages' => [
                "'build-essential'",
                "'vim'",
                "'curl'",
            ],
            'bashaliases' => "super duper cool awesome bash alias\nwith pretty shortcuts",
        ];

        $server = new Server($this->serverArray);

        $this->assertEquals(
            $expected,
            $server->getFormatted()
        );
    }

    public function testGetFormattedReturnsEmptyArrayForEmptyPackages()
    {
        $this->serverArray['packages'];

        $expected = [
            'packages' => [
                "'build-essential'",
                "'vim'",
                "'curl'",
            ],
            'bashaliases' => "super duper cool awesome bash alias\nwith pretty shortcuts",
        ];

        $server = new Server($this->serverArray);

        $this->assertEquals(
            $expected,
            $server->getFormatted()
        );
    }
}
