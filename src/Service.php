<?php

/** @var $app \Pimple */

$app['bucket'] = $app->share(function() {
    return new \Pimple;
});
