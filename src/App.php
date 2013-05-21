<?php

use Silex\Provider;
use Puphpet\Controller;

defined('VENDOR_PATH')
    || define('VENDOR_PATH', __DIR__ . '/../vendor');

defined('VAGRANT_PATH')
    || define('VAGRANT_PATH', VENDOR_PATH . '/jtreminio/vagrant-puppet-lamp');

$app = new Silex\Application;

$env = getenv('APP_ENV') ?: 'prod';

$app->register(new Provider\TwigServiceProvider, [
    'twig.path'     => __DIR__ . '/Puphpet/View',
    'url_generator' => true,
    'twig.options'  => [
        //'cache' => __DIR__ . '/../twig.cache',
    ],
]);

$app->register(new Provider\UrlGeneratorServiceProvider);
$app->register(new Provider\ValidatorServiceProvider);
$app->register(new Provider\DoctrineServiceProvider);

// routing
$app->mount('/', new Puphpet\Controller\Front($app));
$app->mount('/add', new Puphpet\Controller\Add($app));

// services
$app['domain_file'] = function () {
    return new \Puphpet\Domain\File(
        VENDOR_PATH . '/jtreminio/vagrant-puppet-lamp',
        new \Puphpet\Domain\Filesystem()
    );
};

return $app;
