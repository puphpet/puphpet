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
        new Puphpet\Domain\Filesystem()
    );
};
$app['domain_file_configurator'] = function () use ($app) {
    return new Puphpet\Domain\Configurator\File\ConfiguratorHandler($app['dispatcher']);
};
$app['domain.listener.main_source_configurator'] = function() {
    $configurator = new \Puphpet\Domain\Configurator\File\SourceAddingConfigurator(
        new \Puphpet\Domain\Decider\PassDecider(),
        [
            'apt'      => VENDOR_PATH . '/puppetlabs/puppetlabs-apt',
            'stdlib'   => VENDOR_PATH . '/puppetlabs/puppetlabs-stdlib',
            'vcsrepo'  => VENDOR_PATH . '/puppetlabs/puppetlabs-vcsrepo',
            'puppi'    => VENDOR_PATH . '/example42/puppi',
            'php'      => VENDOR_PATH . '/example42/puppet-php',
            'puphpet'  => VENDOR_PATH . '/puphpet/puppet-puphpet',
            'xdebug'   => VENDOR_PATH . '/puphpet/puphpet-xdebug',
            'composer' => VENDOR_PATH . '/puphpet/puphpet-composer',
        ]
    );
    return new \Puphpet\Domain\Configurator\File\Event\Listener\ConfiguratorListener($configurator);
};
$app['domain.listener.optional_source_configurator'] = function() {
    $configuratorApache = new \Puphpet\Domain\Configurator\File\SourceAddingConfigurator(
        new \Puphpet\Domain\Decider\WebserverDecider('apache'),
        [
            'apache' => VENDOR_PATH . '/puphpet/puppet-apache',
        ]
    );
    $configuratorNginx = new \Puphpet\Domain\Configurator\File\SourceAddingConfigurator(
        new \Puphpet\Domain\Decider\WebserverDecider('nginx'),
        [
            'nginx' => VENDOR_PATH . '/jfryman/puppet-nginx',
        ]
    );
    $configuratorMysql = new \Puphpet\Domain\Configurator\File\SourceAddingConfigurator(
        new \Puphpet\Domain\Decider\DatabaseDecider('mysql'),
        [
            'mysql' => VENDOR_PATH . '/puppetlabs/puppetlabs-mysql',
        ]
    );
    $configuratorPostgresql = new \Puphpet\Domain\Configurator\File\SourceAddingConfigurator(
        new \Puphpet\Domain\Decider\DatabaseDecider('postgresql'),
        [
            'concat'     => VENDOR_PATH . '/ripienaar/puppet-concat',
            'postgresql' => VENDOR_PATH . '/puppetlabs/puppetlabs-postgresql',
        ]
    );
    $configuratorPhpMyAdmin = new \Puphpet\Domain\Configurator\File\SourceAddingConfigurator(
        new \Puphpet\Domain\Decider\PhpMyAdminDecider('postgresql'),
        [
            'phpmyadmin' => VENDOR_PATH . '/frastel/puppet-phpmyadmin'
        ]
    );
    return new \Puphpet\Domain\Configurator\File\Event\Listener\ConfiguratorListener([
        $configuratorApache,
        $configuratorNginx,
        $configuratorMysql,
        $configuratorPostgresql,
        $configuratorPhpMyAdmin
    ]);
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
$app['edition_merger'] = function () use ($app) {
    return new Puphpet\Domain\Configuration\EditionMerger(
        $app['dispatcher']
    );
};
$app['file_generator'] = function () use ($app) {
    return new Puphpet\Domain\File\Generator(
        $app['vagrant_compiler'],
        $app['manifest_compiler'],
        $app['readme_compiler'],
        $app['domain_file'],
        $app['domain_file_configurator'],
        new \Puphpet\Domain\Serializer\Serializer(new \Puphpet\Domain\Serializer\Cleaner())
    );
};
$app['configuration_builder'] = function () use ($app) {
    return new Puphpet\Domain\Configuration\ConfigurationBuilder(
        VENDOR_PATH . '/puphpet/puppet-puphpet/files/dot/.bash_aliases',
        new Puphpet\Domain\Filesystem()
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
// main configuration converter enabled for every form
$app['listener.configuration_converter_listener'] = function () use ($app) {
    return new \Puphpet\Domain\Configuration\Event\Listener\ConfigurationConverterListener(
        true, // do it always
        [
            'php'        => '[php][version]',
            'foldertype' => '[provider][local][foldertype]',
        ]
    );
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
        ['symfony' => VENDOR_PATH . '/frastel/puppet-symfony']
    );
    return new \Puphpet\Domain\Configurator\File\Event\Listener\ConfiguratorListener($configurator);
};
$app['plugin.symfony.listener.configuration_converter_listener'] = function () use ($app) {
    return new \Puphpet\Domain\Configuration\Event\Listener\ConfigurationConverterListener(
        'symfony',
        [
       'create_project' => '[project][generate_project]',
       'symfony_version' => '[project][version]',
        ]
    );
};
// Plugin: PuPHPet
$app['plugin.puphpet.configuration_builder'] = function () use ($app) {
    return new Puphpet\Plugins\Puphpet\Configuration\PuphpetConfigurationBuilder(
        VENDOR_PATH . '/puphpet/puppet-puphpet/files/dot/.bash_aliases',
        new Puphpet\Domain\Filesystem()
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
$app['plugin.puphpet.listener.source_configurator'] = function () use ($app) {
    $configurator = new \Puphpet\Domain\Configurator\File\SourceAddingConfigurator(
        new \Puphpet\Plugins\Puphpet\Decider\PuphpetProjectDecider($app['property_access_provider']),
        ['git' => VENDOR_PATH . '/puphpet/puphpet-git']
    );
    return new \Puphpet\Domain\Configurator\File\Event\Listener\ConfiguratorListener($configurator);
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
$app['dispatcher']->addListener('file.configuration', [$app['domain.listener.main_source_configurator'], 'onConfigure'], 200);
$app['dispatcher']->addListener('file.configuration', [$app['domain.listener.optional_source_configurator'], 'onConfigure'], 100);
$app['dispatcher']->addListener('file.configuration', [$app['plugin.symfony.listener.source_configurator'], 'onConfigure']);
$app['dispatcher']->addListener('file.configuration', [$app['plugin.puphpet.listener.source_configurator'], 'onConfigure']);
$app['dispatcher']->addListener(
    'configuration.filter',
    [$app['listener.configuration_converter_listener'], 'onFilter']
);
$app['dispatcher']->addListener(
    'configuration.filter',
    [$app['plugin.symfony.listener.configuration_converter_listener'], 'onFilter']
);

return $app;
