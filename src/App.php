<?php

use Silex\Provider;
use Puphpet\Controller;

defined('VENDOR_PATH')
    || define('VENDOR_PATH', __DIR__ . '/../vendor');

defined('VAGRANT_PATH')
    || define('VAGRANT_PATH', VENDOR_PATH . '/jtreminio/vagrant-puppet-lamp');

$app = new Silex\Application;

$env = getenv('APP_ENV') ? : 'prod';
$app['debug'] = $env != 'prod';

$app->register(new Igorw\Silex\ConfigServiceProvider(__DIR__."/../config/config.yml"));
$app->register(new Igorw\Silex\ConfigServiceProvider(__DIR__."/../config/editions.yml"));

$app->register(
    new Provider\TwigServiceProvider,
    [
        'twig.path'     => __DIR__ . '/Puphpet/View',
        'url_generator' => true,
        'twig.options'  => [
            //'cache' => __DIR__ . '/../twig.cache',
        ],
    ]
);

$app->register(new Provider\UrlGeneratorServiceProvider);
$app->register(new Provider\ValidatorServiceProvider);
$app->register(new Provider\DoctrineServiceProvider);
$app->register(new Nicl\Silex\MarkdownServiceProvider, ['markdown.parser' => 'extra']);

// routing
$app->mount('/', new Puphpet\Controller\Front($app));
$app->mount('/add', new Puphpet\Controller\Add($app));

// services
$app['domain_file'] = function () {
    return new Puphpet\Domain\File(
        VAGRANT_PATH,
        new Puphpet\Domain\Filesystem()
    );
};
$app['domain_file_configurator'] = function () {
    return new Puphpet\Domain\Configurator\File\ConfiguratorHandler(
        [
            new Puphpet\Domain\Configurator\File\Module\NginxConfigurator(VENDOR_PATH),
            new Puphpet\Domain\Configurator\File\Module\PostgreSQLConfigurator(VENDOR_PATH),
            new Puphpet\Domain\Configurator\File\Module\PhpMyAdminConfigurator(VENDOR_PATH),
        ]
    );
};
$app['manifest_formatter'] = function () {
    return new Puphpet\Domain\Compiler\Manifest\Formatter(
        [
            'server'     => new Puphpet\Domain\PuppetModule\Server(array()),
            'apache'     => new Puphpet\Domain\PuppetModule\Apache(array()),
            'nginx'      => new Puphpet\Domain\PuppetModule\Nginx(array()),
            'mysql'      => new Puphpet\Domain\PuppetModule\MySQL(array()),
            'postgresql' => new Puphpet\Domain\PuppetModule\PostgreSQL(array()),
            'php'        => new Puphpet\Domain\PuppetModule\PHP(array()),
        ]
    );
};
$app['manifest_configuration_formatter'] = function () use ($app) {
    return new Puphpet\Domain\Compiler\Manifest\ConfigurationFormatter($app['manifest_formatter']);
};
$app['manifest_compiler'] = function () use ($app) {
    return new Puphpet\Domain\Compiler\Compiler(
        $app['dispatcher'],
        $app['twig'],
        'Vagrant/manifest.pp.twig',
        'manifest'
    );
};
$app['readme_compiler'] = function () use ($app) {
    return new Puphpet\Domain\Compiler\Compiler(
        $app['dispatcher'],
        $app['twig'],
        'Vagrant/README.twig',
        'readme'
    );
};
$app['vagrant_compiler'] = function () use ($app) {
    return new Puphpet\Domain\Compiler\Compiler(
        $app['dispatcher'],
        $app['twig'],
        'Vagrant/Vagrantfile.twig',
        'vagrant'
    );
};
$app['property_access_provider'] = function () {
    return new Puphpet\Domain\Configuration\PropertyAccessProvider();
};
$app['edition'] = function () use ($app) {
    return new Puphpet\Domain\Configuration\Edition($app['property_access_provider']);
};
$app['edition_provider'] = function() use ($app) {
    return new Puphpet\Domain\Configuration\EditionProvider(
        $app['edition'],
        $app['editions'],
        $app['edition_default']
    );
};
$app['file_generator'] = function () use ($app) {
    return new Puphpet\Domain\File\Generator(
        $app['vagrant_compiler'],
        $app['manifest_compiler'],
        $app['readme_compiler'],
        $app['domain_file'],
        $app['domain_file_configurator']
    );
};
$app['configuration_file_generator'] = function () use ($app) {
    return new Puphpet\Domain\File\ConfigurationGenerator(
        $app['file_generator'],
        $app['manifest_configuration_formatter']
    );
};
$app['markdown'] = function() use ($app) {
    return new dflydev\markdown\MarkdownParser;
};

return $app;
