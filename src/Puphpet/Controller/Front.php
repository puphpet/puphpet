<?php

namespace Puphpet\Controller;

use Puphpet\Controller;
use Puphpet\Domain;

use Silex\Application as App;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class Front extends Controller
{
    public function connect(App $app)
    {
        /** @var $controllers ControllerCollection */
        $controllers = $app['controllers_factory'];

        $controllers->get('/', [$this, 'indexAction'])
            ->bind('homepage');

        return $controllers;
    }

    public function indexAction(Request $request, App $app)
    {
        return '';
    }
}
