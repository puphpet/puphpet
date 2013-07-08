<?php

namespace Puphpet\Tests\Domain\Configuration\File\Module;

use Puphpet\Domain\Decider\DatabaseDecider;
use Puphpet\Domain\Decider\WebserverDecider;

class DatabaseDeciderTest extends \PHPUnit_Framework_TestCase
{
    private $database = 'postgresql';

    /**
     * @dataProvider provideUnsupported
     */
    public function testSupportReturnsFalseWithUnsupportedConfiguration($configuration)
    {
        $decider = new DatabaseDecider($this->database);
        $this->assertFalse($decider->supports($configuration));
    }

    static public function provideUnsupported()
    {
        return [
            [['foo' => 'bar']],
            [array()],
            [['database' => 'postgresql']],
            [['database' => 'postgresql', 'postgresql' => 'foo']],
            [['database' => 'postgresql', 'postgresql' => null]],
        ];
    }

    /**
     * @dataProvider provideSupported
     */
    public function testSupportReturnsTrueWithSupportedConfiguration($configuration)
    {
        $decider = new DatabaseDecider($this->database);
        $this->assertTrue($decider->supports($configuration));
    }

    static public function provideSupported()
    {
        return [
            [['database' => 'postgresql', 'postgresql' => array()]],
        ];
    }
}
