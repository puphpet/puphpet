<?php

namespace Puphpet\Tests\Domain\Configuration\File\Module;

use Puphpet\Domain\Decider\PhpMyAdminDecider;

class PhpMyAdminDeciderTest extends \PHPUnit_Framework_TestCase
{
    /**
     * @dataProvider provideUnsupported
     */
    public function testSupportReturnsFalseWithUnsupportedConfiguration($configuration)
    {
        $decider = new PhpMyAdminDecider();
        $this->assertFalse($decider->supports($configuration));
    }

    static public function provideUnsupported()
    {
        return [
            [['foo' => 'bar']],
            [array()],
            [['mysql' => array()]],
            [['mysql' => ['phpmyadmin' => false]]],
            [['mysql' => ['phpmyadmin' => 0]]],
            [['mysql' => ['phpmyadmin' => '']]],
        ];
    }

    /**
     * @dataProvider provideSupported
     */
    public function testSupportReturnsTrueWithSupportedConfiguration($configuration)
    {
        $decider = new PhpMyAdminDecider();
        $this->assertTrue($decider->supports($configuration));
    }

    static public function provideSupported()
    {
        return [
            [['mysql' => ['phpmyadmin' => true]]],
        ];
    }
}
