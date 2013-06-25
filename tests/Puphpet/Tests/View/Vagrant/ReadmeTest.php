<?php

namespace Puphpet\Tests\View\Vagrant;

use Puphpet\Tests\Base;

/**
 * @group functional
 */
class ReadmeTest extends Base
{
    public function setUp()
    {
        $this->createApplication();
    }

    /**
     * This test is a simple functional test on rendering the manifest template.
     * It does not analyze its content but it checks if there is rendered something
     * useful or if any error occurs during rendering.
     */
    public function testRender()
    {
        $parameters = [
            'box'         => ['name' => 'precise64', 'url' => 'http://files.vagrantup.com/precise64.box'],
            'webserver'   => 'apache',
            'php_service' => 'apache',
            'php'         => [
                'version' => 'php55',
                'modules' => [
                    'php'      => ['php5-cli'],
                    'pear'     => ['installed' => true],
                    'pecl'     => array(),
                    'composer' => ['installed' => true],
                    'xdebug'   => ['installed' => true],
                    'xhprof'   => ['installed' => true],
                ],
                'inilist'  => [
                    'php'    => [
                        'date.timezone = "America/Chicago"',
                    ],
                    'custom' => [
                        'display_errors = On',
                        'error_reporting = 1'
                    ]
                ],
            ],
            'database'    => 'mysql',
        ];

        $rendered = $this->app['readme_compiler']->compile($parameters);

        $this->assertContains('precise64 (http://files.vagrantup.com/precise64.box)', $rendered);
        $this->assertContains('PHP 5.5', $rendered);
        $this->assertContains('apache', $rendered);
        $this->assertContains('mysql', $rendered);
    }
}
