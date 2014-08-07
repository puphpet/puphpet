<?php

use Symfony\Component\HttpFoundation\Request;

umask(0000); // This will let the permissions be 0777

foreach (['SCRIPT_URL', 'REQUEST_URI', 'SCRIPT_NAME', 'ORIG_SCRIPT_FILENAME', 'PATH_TRANSLATED', 'PHP_SELF'] as $key) {
    if (!empty($_SERVER[$key])) {
        $_SERVER[$key] = str_replace('//', '/', $_SERVER[$key]);
    }
}

$loader = require_once __DIR__.'/../app/bootstrap.php.cache';

$loader->register(true);

require_once __DIR__.'/../app/AppKernel.php';

$kernel = new AppKernel('prod', false);
$kernel->loadClassCache();

Request::enableHttpMethodParameterOverride();
$request = Request::createFromGlobals();
$response = $kernel->handle($request);
$response->send();
$kernel->terminate($request, $response);
