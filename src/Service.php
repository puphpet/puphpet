<?php

use Puphpet\Domain;

/** @var $app \Pimple */

$app['bucket'] = $app->share(function() {
    return new \Pimple;
});

$app['pluginHandler'] = $app->share(function($app) {
    return new Domain\PluginHandler(new Domain\PluginRegister($app['bucket']), $app['twig']);
});
