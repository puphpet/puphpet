<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\PuppetModule\PostgreSQL;

class PostgreSQLTest extends \PHPUnit_Framework_TestCase
{
    protected $postgresqlArray = array();

    public function setUp()
    {
        $this->postgresqlArray = [
            'root'   => 'rootPassword',
            'dbuser' => [
                [
                    'privileges' => [
                        'ALL',
                    ],
                    'user'     => 'user1',
                    'password' => 'password1',
                    'dbname'   => 'dbname1',
                ],
                [
                    'privileges' => [
                        'ALTER',
                        'CREATE',
                        'TEMPORARY',
                    ],
                    'user'     => 'user2',
                    'password' => 'password2',
                    'dbname'   => 'dbname2',
                ],
            ],
        ];
    }

    /**
     * @dataProvider providerGetFormattedReturnsEmptyArrayWhenPostgreSQLPropertyEmpty
     */
    public function testGetFormattedReturnsEmptyArrayWhenPostgreSQLPropertyEmpty($param)
    {
        $postgresql = new PostgreSQL($param);

        $expected = array();

        $this->assertEquals(
            $expected,
            $postgresql->getFormatted()
        );
    }

    public function providerGetFormattedReturnsEmptyArrayWhenPostgreSQLPropertyEmpty()
    {
        return [
            [array()],
            [0],
            [''],
        ];
    }

    public function testGetFormattedRemovesIncompleteSubmissions()
    {
        $expected = $this->postgresqlArray;

        unset($expected['dbuser'][1], $expected['dbuser'][2]);

        unset($this->postgresqlArray['dbuser'][1]['user']);

        unset($this->postgresqlArray['dbuser'][2]['dbname']);

        $postgresql = new PostgreSQL($this->postgresqlArray);

        $this->assertEquals(
            $expected,
            $postgresql->getFormatted()
        );
    }

    public function testGetFormattedReturnsArrayWithEmptyKeyIfNoDbuserValues()
    {
        $this->postgresqlArray['dbuser'] = false;

        $expected = [
            'root'   => 'rootPassword',
            'dbuser' => array()
        ];

        $postgresql = new PostgreSQL($this->postgresqlArray);

        $this->assertEquals(
            $expected,
            $postgresql->getFormatted()
        );
    }
}
