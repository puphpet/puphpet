<?php

namespace Puphpet\Tests;

use \Silex\Application;
use \Silex\WebTestCase;

class Base extends WebTestCase
{
    /** @var Application */
    protected $app;

    public function createApplication()
    {
        putenv('APP_ENV=dev');

        // Silex
        require_once __DIR__ . '/../../../src/App.php';

        /** @var Application $app */
        $this->app = $app;

        return $this->app;
    }
}
