<?php

use Silex\Provider;
use Puphpet\Controller;

$app = new Silex\Application;

$env = getenv('APP_ENV') ? : 'prod';
$app['debug'] = $env != 'prod';

$app->register(
    new Provider\TwigServiceProvider, [
        'twig.path'     => [
            __DIR__ . '/Puphpet/View',
            __DIR__ . '/Puphpet/Plugin',
        ],
        'url_generator' => true,
    ]
);

$app->register(new Provider\UrlGeneratorServiceProvider);
$app->register(new Provider\ValidatorServiceProvider);

$app['jsonConfigDriver'] = function() {
    return new Igorw\Silex\JsonConfigDriver();
};

// routing
$app->mount('/', new Puphpet\Controller\Front($app));

// services
require_once __DIR__ . '/Service.php';

return $app;
