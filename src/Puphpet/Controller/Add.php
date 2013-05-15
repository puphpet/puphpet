<?php

namespace Puphpet\Controller;

use Puphpet\Controller;

use Silex\Application;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session;

class Add extends Controller
{
    public function connect(Application $app)
    {
        /** @var $controllers ControllerCollection */
        $controllers = $app['controllers_factory'];

        $controllers->get('/vhost', [$this, 'vhostAction'])
             ->bind('add.vhost');

        $controllers->get('/dbuser', [$this, 'dbuserAction'])
             ->bind('add.dbuser');

        return $controllers;
    }

    public function vhostAction(Request $request)
    {
        $vhostNum = $request->get('id');

        return $this->twig()->render(
            'Front/Tabs/Apache/vhost.html.twig',
            ['vhostNum' => $vhostNum]
        );
    }

    public function dbuserAction(Request $request)
    {
        $dbUserNum = $request->get('id');

        return $this->twig()->render(
            'Front/Tabs/mysql/dbuser.html.twig',
            ['dbNum' => $dbUserNum]
        );
    }
}
