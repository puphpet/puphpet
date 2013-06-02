<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\PuppetModule\MySQL;

class MySQLTest extends \PHPUnit_Framework_TestCase
{
    protected $mysqlArray = array();

    public function setUp()
    {
        $this->mysqlArray = [
            'root'       => 'rootPassword',
            'phpmyadmin' => true,
            'dbuser'     => [
                [
                    'privileges' => [
                        'ALL',
                    ],
                    'user'       => 'user1',
                    'password'   => 'password1',
                    'dbname'     => 'dbname1',
                    'host'       => 'localhost',
                ],
                [
                    'privileges' => [
                        'ALTER',
                        'CREATE',
                        'CREATE TEMPORARY TABLES',
                    ],
                    'user'       => 'user2',
                    'password'   => 'password2',
                    'dbname'     => 'dbname2',
                    'host'       => 'remotehost',
                ],
                [
                    'privileges' => [
                        'CREATE',
                    ],
                    'user'       => 'user3',
                    'password'   => 'password3',
                    'dbname'     => 'dbname3',
                    'host'       => 'amazon',
                ],
            ],
        ];
    }

    /**
     * @dataProvider providerGetFormattedReturnsEmptyArrayWhenMySQLPropertyEmpty
     */
    public function testGetFormattedReturnsEmptyArrayWhenMySQLPropertyEmpty($param)
    {
        $mysql = new MySQL($param);

        $expected = array();

        $this->assertEquals(
            $expected,
            $mysql->getFormatted()
        );
    }

    public function providerGetFormattedReturnsEmptyArrayWhenMySQLPropertyEmpty()
    {
        return [
            [array()],
            [0],
            [''],
        ];
    }

    public function testGetFormattedRemovesIncompleteSubmissions()
    {
        $expected = $this->mysqlArray;

        unset($expected['dbuser'][1], $expected['dbuser'][2]);

        unset($this->mysqlArray['dbuser'][1]['user']);

        unset($this->mysqlArray['dbuser'][2]['dbname']);

        $mysql = new MySQL($this->mysqlArray);

        $this->assertEquals(
            $expected,
            $mysql->getFormatted()
        );
    }

    public function testGetFormattedReturnsArrayWithEmptyKeyIfNoDbuserValues()
    {
        $this->mysqlArray['dbuser'] = false;

        $expected = [
            'root'       => 'rootPassword',
            'phpmyadmin' => true,
            'dbuser'     => array()
        ];

        $mysql = new MySQL($this->mysqlArray);

        $this->assertEquals(
            $expected,
            $mysql->getFormatted()
        );
    }

    public function testGetFormattedReturnsAlwaysPhpMyAdminFlag()
    {
        $mysql = new MySQL(['foo' => 'bar']);

        $expected = [
            'foo'        => 'bar',
            'phpmyadmin' => false,
            'dbuser'     => array(),
        ];

        $this->assertEquals($expected, $mysql->getFormatted());
    }
}
