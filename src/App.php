<?php

use Silex\Provider;
use Puphpet\Controller;

defined('VENDOR_PATH')
    || define('VENDOR_PATH', __DIR__ . '/../vendor');

defined('VAGRANT_PATH')
    || define('VAGRANT_PATH', __DIR__ . '/../puppet/modules');

$app = new Silex\Application;

$env = getenv('APP_ENV') ? : 'prod';
$app['debug'] = $env != 'prod';

$app->register(new Igorw\Silex\ConfigServiceProvider(__DIR__ . '/../config/config.yml'));
$app->register(new Igorw\Silex\ConfigServiceProvider(__DIR__ . '/../config/editions.yml'));

$app->register(
    new Provider\TwigServiceProvider,
    [
        'twig.path'     => __DIR__ . '/Puphpet/View',
        'url_generator' => true,
        'twig.options'  => [
            // 'cache' => ($app['debug'] ? false : __DIR__ . '/../twig.cache'),
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
$app->mount('/quickstart', new Puphpet\Controller\Quickstart($app));

// services
$app['domain_file'] = function () {
    return new Puphpet\Domain\File(
        VAGRANT_PATH,
        new Puphpet\Domain\Filesystem()
    );
};
$app['domain_file_configurator'] = function () use ($app) {
    return new Puphpet\Domain\Configurator\File\ConfiguratorHandler(
        $app['dispatcher'],
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
            // container to pass custom configurations to the edition module
            'project'    => new Puphpet\Domain\PuppetModule\Passthru(array()),
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
$app['edition_provider'] = function () use ($app) {
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
$app['markdown'] = function () use ($app) {
    return new dflydev\markdown\MarkdownParser;
};

// overwriting the native filesystem loader, we need support of several view folders
// every (quickstart) edition has to define its view folder and according namespace here
$app['twig.loader.filesystem'] = $app->share(
    function ($app) {
        $fs = new \Twig_Loader_Filesystem($app['twig.path']);
        $fs->addPath(__DIR__ . '/Puphpet/Plugins/Symfony/View', 'Symfony');
        $fs->addPath(__DIR__ . '/Puphpet/Plugins/Puphpet/View', 'Puphpet');

        return $fs;
    }
);

// Start Plugins
// Plugin: Symfony
$app['plugin.symfony.configuration_builder'] = function () use ($app) {
    return new Puphpet\Plugins\Symfony\Configuration\SymfonyConfigurationBuilder(
        VENDOR_PATH . '/puphpet/puppet-puphpet/files/dot/.bash_aliases',
        new Puphpet\Domain\Filesystem()
    );
};
$app['plugin.symfony.create_project_decider'] = function () use ($app) {
    return new \Puphpet\Plugins\Symfony\Compiler\SymfonyCreateProjectDecider($app['property_access_provider']);
};
$app['plugin.symfony.manipulator.project'] = function () use ($app) {
    return new \Puphpet\Domain\Compiler\AdditionalContentManipulator(
        $app['plugin.symfony.create_project_decider'],
        $app['twig'],
        '@Symfony/Vagrant/symfony_project.pp.twig'
    );
};
$app['plugin.symfony.listener.source_configurator'] = function () use ($app) {
    $configurator = new \Puphpet\Domain\Configurator\File\SourceAddingConfigurator(
        $app['plugin.symfony.create_project_decider'],
        'symfony',
        VENDOR_PATH . '/frastel/puppet-symfony'
    );
    return new \Puphpet\Domain\Configurator\File\Event\Listener\ConfiguratorListener($configurator);
};
// Plugin: PuPHPet
$app['plugin.puphpet.configuration_builder'] = function () use ($app) {
    return new Puphpet\Plugins\Puphpet\Configuration\PuphpetConfigurationBuilder(
        VENDOR_PATH . '/puphpet/puppet-puphpet/files/dot/.bash_aliases'
    );
};
$app['plugin.puphpet.clone_project_decider'] = function () use ($app) {
    return new \Puphpet\Plugins\Puphpet\Compiler\PuphpetCreateProjectDecider($app['property_access_provider']);
};
$app['plugin.puphpet.manipulator.project'] = function () use ($app) {
    return new \Puphpet\Domain\Compiler\AdditionalContentManipulator(
        $app['plugin.puphpet.clone_project_decider'],
        $app['twig'],
        '@Puphpet/Vagrant/clone.pp.twig'
    );
};
// End Plugins

$app['manifest.compilation_listener'] = function () use ($app) {
    return new \Puphpet\Domain\Compiler\Event\Listener\CompilationListener([
        $app['plugin.symfony.manipulator.project'],
        $app['plugin.puphpet.manipulator.project']
    ]);
};

// @TODO this mechanism is without lazy loading :/
// maybe sth like ContainerAwareEventDispatcher as to be added here?
// registering on the event which is fired after the manifest is compiled
$app['dispatcher']->addListener('compile.manifest.finish', [$app['manifest.compilation_listener'], 'onCompile']);
$app['dispatcher']->addListener('file.configuration', [$app['plugin.symfony.listener.source_configurator'], 'onConfigure']);

return $app;
