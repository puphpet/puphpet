<?php

namespace Puphpet\Tests\Domain;

use Puphpet\Tests\Base;
use Puphpet\Domain\Apache;

class ApacheTest extends Base
{
    /**
     * @param $modules
     * @param $expectedResult
     *
     * @dataProvider providerTestFormatModulesReturnsExpected
     */
    public function testFormatModulesReturnsExpected($modules, $expectedResult)
    {
        $apache = new Apache;

        $this->assertEquals(
            $apache->formatModules($modules),
            $expectedResult
        );
    }

    public function providerTestFormatModulesReturnsExpected()
    {
        return [
            ['', []],
            [[], []],
            [['foo'], ['foo']]
        ];
    }

    public function testFormatVhostReturnsExpected()
    {
        $vhost1 = [
            'serveraliases' => 'www.awesome.dev,test.awesome.dev, cool.google.com',
            'envvars'       => 'IS_AWESOME yes, IS_GOOD_TEST yes,SHOULD_PASS yes',
        ];
        $vhost2 = [
            'serveraliases' => 'www.jtreminio.dev,    test.jtreminio.dev,',
            'envvars'       => '',
        ];

        $vhosts = [$vhost1, $vhost2];

        $expectedResult = [
            0 => [
                'serveraliases' => [
                    "'www.awesome.dev'",
                    "'test.awesome.dev'",
                    "'cool.google.com'",
                ],
                'envvars'       => [
                    "'IS_AWESOME yes'",
                    "'IS_GOOD_TEST yes'",
                    "'SHOULD_PASS yes'",
                ],
            ],
            1 => [
                'serveraliases' => [
                    "'www.jtreminio.dev'",
                    "'test.jtreminio.dev'",
                ],
                'envvars'       => [],
            ],
        ];

        $apache = new Apache;

        $result = $apache->formatVhosts($vhosts);

        $this->assertEquals(
            $expectedResult,
            $result
        );
    }
}
