<?php

namespace Puphpet\Controller;

use Puphpet\Controller;

use Silex\Application;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;

class Add extends Controller
{
    public function connect(Application $app)
    {
        /** @var $controllers ControllerCollection */
        $controllers = $app['controllers_factory'];

        $controllers->get('/vhost', [$this, 'vhostAction'])
             ->bind('add.vhost');

        $controllers->get('/sharedfolder', [$this, 'sharedfolderAction'])
            ->bind('add.sharedfolder');

        $controllers->get('/mysql/dbuser', [$this, 'mysqldbuserAction'])
             ->bind('add.mysql.dbuser');

        $controllers->get('/postgresql/dbuser', [$this, 'postgresqldbuserAction'])
             ->bind('add.postgresql.dbuser');

        return $controllers;
    }

    public function vhostAction(Request $request)
    {
        return $this->twig()->render(
            'Front/Tabs/Webserver/Apache/vhost.html.twig',
            ['vhostNum' => $request->get('id')]
        );
    }

    public function sharedfolderAction(Request $request)
    {
        $provider = $request->get('provider');

        return $this->twig()->render(
            "Front/Tabs/Vagrant/Box/SharedFolder/{$provider}.html.twig",
            ['sharedFolderNum' => $request->get('id'), 'provider' => $provider]
        );
    }

    public function mysqldbuserAction(Request $request)
    {
        return $this->twig()->render(
            'Front/Tabs/Database/MySQL/dbuser.html.twig',
            ['dbNum' => $request->get('id')]
        );
    }

    /**
     * Renders "Add PostgreSQL database" template
     *
     * @param  Request $request
     */
    public function postgresqldbuserAction(Request $request)
    {
        return $this->twig()->render(
            'Front/Tabs/Database/PostgreSQL/dbuser.html.twig',
            ['dbNum' => $request->get('id')]
        );
    }
}
