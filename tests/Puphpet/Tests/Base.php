<?php

namespace Puphpet\Tests\Unit;

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
        $this->app = require __DIR__ . '/../../../../src/App.php';

        return $this->app;
    }
}
