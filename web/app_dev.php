<?php

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Debug\Debug;

umask(0000);

if (getenv('APP_ENV') !== 'dev') {
    exit;
}

error_reporting(E_ALL);
ini_set('display_errors', '1');

/**
 * @var Composer\Autoload\ClassLoader $loader
 */
$loader = require __DIR__.'/../app/autoload.php';
Debug::enable();

$kernel = new AppKernel('dev', true);
$kernel->loadClassCache();
$request = Request::createFromGlobals();
$response = $kernel->handle($request);
$response->send();
$kernel->terminate($request, $response);
