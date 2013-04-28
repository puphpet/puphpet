<?php

require __DIR__ . '/Container.php';

$container = new Container;

$app = $container->getApp();

$env = getenv('APP_ENV') ?: 'prod';

$app->register(new Igorw\Silex\ConfigServiceProvider(__DIR__ . "/../config/{$env}.yml"));

$app->register(new Silex\Provider\TwigServiceProvider(), array(
    'twig.path'     => __DIR__ . '/Puphpet/View',
    'url_generator' => true,
    'twig.options'  => array(
        'cache' => __DIR__ . '/../twig.cache',
    ),
));

$app->register(new Silex\Provider\UrlGeneratorServiceProvider());
$app->register(new Silex\Provider\ValidatorServiceProvider());
$app->register(new Silex\Provider\DoctrineServiceProvider());

require_once __DIR__ . '/Controllers.php';
