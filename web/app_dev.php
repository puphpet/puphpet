<?php

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Debug\Debug;

if (getenv('APP_ENV') !== 'dev') {
    exit;
}

error_reporting(E_ALL);
ini_set('display_errors', '1');
ini_set('opcache.enable', '0');

umask(0000);

$loader = require_once __DIR__.'/../app/bootstrap.php.cache';
Debug::enable();

require_once __DIR__.'/../app/AppKernel.php';

$kernel = new AppKernel('dev', true);
$kernel->loadClassCache();
Request::enableHttpMethodParameterOverride();
$request = Request::createFromGlobals();
$response = $kernel->handle($request);
$response->send();
$kernel->terminate($request, $response);
