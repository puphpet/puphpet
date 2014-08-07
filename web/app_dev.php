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

foreach (['SCRIPT_URL', 'REQUEST_URI', 'SCRIPT_NAME', 'ORIG_SCRIPT_FILENAME', 'PATH_TRANSLATED', 'PHP_SELF'] as $key) {
    if (!empty($_SERVER[$key])) {
        $_SERVER[$key] = str_replace('//', '/', $_SERVER[$key]);
    }
}

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
