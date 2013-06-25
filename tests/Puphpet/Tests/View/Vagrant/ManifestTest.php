<?php

namespace Puphpet\Tests\View\Vagrant;

use Puphpet\Tests\Base;

/**
 * @group functional
 */
class ManifestTest extends Base
{
    /**
     * @var array
     */
    private $parameters;

    public function setUp()
    {
        $this->createApplication();

        $this->parameters = [
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
                'version' => 'php55',
                'modules' => [
                    'php'      => ['php5-cli'],
                    'pear'     => ['installed' => true],
                    'pecl'     => array(),
                    'composer' => ['installed' => true],
                    'xdebug'   => ['installed' => true],
                    'xhprof'   => ['installed' => true],
                ],
                'inilist' => [
                    'php'    => [
                        'date.timezone = "America/Chicago"',
                    ],
                    'custom' => [
                        'display_errors = On',
                        'error_reporting = 1'
                    ]
                ],
            ],
            'mysql'       => [
                'root'       => 'rootpwd',
                'phpmyadmin' => false,
                'dbuser'     => [
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

    }


    /**
     * This test is a simple functional test on rendering the manifest template.
     * It does not analyze its content but it checks if there is rendered something
     * useful or if any error occurs during rendering.
     */
    public function testRender()
    {
        $rendered = $this->app['twig']->render('Vagrant/manifest.pp.twig', $this->parameters);

        $this->assertContains('apt-get update', $rendered);
        $this->assertContains("class { 'apache'", $rendered);
        $this->assertContains("apache::module { 'foo'", $rendered);
        $this->assertContains("apt::ppa { 'ppa:ondrej/php5-experimental'", $rendered);
        $this->assertContains("php::module { 'php5-cli'", $rendered);
        $this->assertContains("root_password => 'rootpwd'", $rendered);
        $this->assertContains("mysql::grant { 'test_dbname'", $rendered);
        $this->assertContains('date.timezone = "America/Chicago"', $rendered);

        $this->assertNotContains('phpmyadmin', $rendered);

        $this->doLinting($rendered);
    }

    public function testRenderWithPhpMyAdmin()
    {
        $this->parameters['mysql']['phpmyadmin'] = true;

        $rendered = $this->app['twig']->render('Vagrant/manifest.pp.twig', $this->parameters);

        $this->assertContains("class { 'phpmyadmin':", $rendered);

        $this->doLinting($rendered);
    }


    private function doLinting($rendered)
    {
        // check first if puppet-lint is installed
        $output = shell_exec('which puppet-lint');
        if (empty($output)) {
            $msg = '"puppet-lint" is not installed on your machine, linting of manifest is aborted!';
            $this->markTestSkipped($msg);
        }

        // dump generated dump file to cache dir
        $filename = realpath(__DIR__ . '/../../../../../cache') . '/manifest_lint.pp';
        file_put_contents($filename, $rendered);

        $output = shell_exec("puppet-lint $filename");

        // if linting is OK the response has to be empty
        $msg = sprintf('Result of puppet-lint is not empty: "%s". Manifest dumped to "%s"', $output, $filename);
        $this->assertEmpty($output, $msg);
    }
}
