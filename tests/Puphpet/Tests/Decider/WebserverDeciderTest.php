<?php

namespace Puphpet\Tests\Domain\Configuration\File\Module;

use Puphpet\Domain\Decider\WebserverDecider;

class WebserverDeciderTest extends \PHPUnit_Framework_TestCase
{
    private $webserver = 'nginx';

    /**
     * @dataProvider provideUnsupported
     */
    public function testSupportReturnsFalseWithUnsupportedConfiguration($configuration)
    {
        $decider = new WebserverDecider($this->webserver);
        $this->assertFalse($decider->supports($configuration));
    }

    static public function provideUnsupported()
    {
        return [
            [['foo' => 'bar']],
            [array()],
            [['webserver' => 'nginx']],
            [['webserver' => 'nginx', 'nginx' => 'foo']],
            [['webserver' => 'nginx', 'nginx' => null]],
        ];
    }

    /**
     * @dataProvider provideSupported
     */
    public function testSupportReturnsTrueWithSupportedConfiguration($configuration)
    {
        $decider = new WebserverDecider($this->webserver);
        $this->assertTrue($decider->supports($configuration));
    }

    static public function provideSupported()
    {
        return [
            [['webserver' => 'nginx', 'nginx' => array()]],
        ];
    }
}
