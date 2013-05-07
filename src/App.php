<?php

use Silex\Provider;

require __DIR__ . '/Container.php';

$container = new Container;

$app = $container->getApp();

$env = getenv('APP_ENV') ?: 'prod';

$app->register(new Igorw\Silex\ConfigServiceProvider(__DIR__ . "/../config/{$env}.yml"));

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

require_once __DIR__ . '/Controllers.php';
