<?php

use Symfony\Component\HttpFoundation\Request;

umask(0000); // This will let the permissions be 0777

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
