<?php

namespace Puphpet\Tests\View\Vagrant;

use Puphpet\Tests\Base;

/**
 * @group functional
 */
class ManifestTest extends Base
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
            'webserver'   => 'apache',
            'php_service' => 'apache',
            'server'      => ['packages' => ['foo', 'bar']],
            'apache'      => [
                'vhosts'  => [
                    [
                        'servername'    => 'myserver',
                        'serveraliases' => array(),
                        'envvars'       => array(),
                        'docroot'       => '/var/www',
                        'port'          => 80,
                    ]
                ],
                'modules' => ['foo', 'bar'],
            ],
            'php'         => [
                'pear'     => true,
                'php54'    => true,
                'xdebug'   => true,
                'composer' => true,
                'modules'  => ['php' => ['php5-cli'], 'pear' => array(), 'pecl' => array()],
                'inilist'  => [
                    'php' => [
                        'date.timezone = "America/Chicago"',
                    ],
                    'custom' => [
                        'display_errors = On',
                        'error_reporting = 1'
                    ]
                ],
            ],
            'mysql'       => [
                'root'   => 'rootpwd',
                'dbuser' => [
                    [
                        'dbname'     => 'test_dbname',
                        'privileges' => [],
                        'user'       => 'test_user',
                        'password'   => 'test_password',
                        'host'       => 'test_host',
                    ]
                ]
            ]
        ];

        $rendered = $this->app['twig']->render('Vagrant/manifest.pp.twig', $parameters);

        $this->assertContains('apt-get update', $rendered);
        $this->assertContains("class { 'apache'", $rendered);
        $this->assertContains("apache::module { 'foo'", $rendered);
        $this->assertContains("apt::ppa { 'ppa:ondrej/php5'", $rendered);
        $this->assertContains("php::module { 'php5-cli'", $rendered);
        $this->assertContains("root_password => 'rootpwd'", $rendered);
        $this->assertContains("mysql::grant { 'test_dbname'", $rendered);
        $this->assertContains('date.timezone = "America/Chicago"', $rendered);
    }
}
