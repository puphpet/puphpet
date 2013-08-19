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
        // todo: replace this with get/post request data
        /** @var \Igorw\Silex\JsonConfigDriver $jsonConfigDriver */
        $jsonConfigDriver = $app['jsonConfigDriver'];
        $data = $jsonConfigDriver->load(__DIR__ . '/../../../data/sample1.json');

        /** @var Domain\PluginHandler $pluginHandler */
        $pluginHandler = $app['pluginHandler'];
        $pluginHandler->setData($data)
            ->process();
    }
}
