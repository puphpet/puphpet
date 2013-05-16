<?php

namespace Puphpet\Controller;

use Puphpet\Controller;

use Puphpet\Domain;
use Silex\Application;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session;

class Front extends Controller
{
    public function connect(Application $app)
    {
        /** @var $controllers ControllerCollection */
        $controllers = $app['controllers_factory'];

        $controllers->get('/', [$this, 'indexAction'])
             ->bind('homepage');

        $controllers->post('/create', [$this, 'createAction'])
             ->bind('create');

        $controllers->get('/about', [$this, 'aboutAction'])
             ->bind('about');

        $controllers->get('/help', [$this, 'helpAction'])
             ->bind('help');

        return $controllers;
    }

    public function indexAction()
    {
        return $this->twig()->render(
            'Front/index.html.twig',
            ['currentPage' => 'home']
        );
    }

    public function aboutAction()
    {
        return $this->twig()->render(
            'Front/about.html.twig',
            ['currentPage' => 'about']
        );
    }

    public function helpAction()
    {
        return $this->twig()->render(
            'Front/help.html.twig',
            ['currentPage' => 'help']
        );
    }

    public function createAction(Request $request)
    {
        $box    = $request->get('box');
        $php    = $request->get('php');
        $mysql  = $request->get('mysql');

        $server = new Domain\Server($request->get('server'));
        $server = $server->getFormatted();

        $apache = new Domain\Apache($request->get('apache'));
        $apache = $apache->getFormatted();

        $domainMySQL  = new Domain\MySQL;
        $domainPHP    = new Domain\PHP;

        $php['modules']     = $domainPHP->formatModules($php['modules']);
        $php['pearmodules'] = $domainPHP->formatModules($php['pearmodules']);
        $php['pecl']        = $domainPHP->formatModules($php['pecl']);

        $mysql['db'] = $domainMySQL->removeIncomplete($mysql['db']);

        $vagrantFile = $this->twig()->render('Vagrant/Vagrantfile.twig', ['box' => $box]);
        $manifest    = $this->twig()->render('Vagrant/manifest.twig', [
            'server' => $server,
            'apache' => $apache,
            'php'    => $php,
            'mysql'  => $mysql,
        ]);

        $domainFile = new Domain\File(__DIR__ . '/../repo');
        $domainFile->createArchive([
            'vagrantFile'  => $vagrantFile,
            'manifest'     => $manifest,
            'bash_aliases' => $server['bashaliases'],
        ]);
        $domainFile->downloadFile();

        return;
    }
}
