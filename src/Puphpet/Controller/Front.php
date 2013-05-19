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
        $box = $request->request->get('box');

        $server = new Domain\PuppetModule\Server($request->request->get('server'));
        $apache = new Domain\PuppetModule\Apache($request->request->get('apache'));
        $mysql  = new Domain\PuppetModule\MySQL($request->request->get('mysql'));
        $php    = new Domain\PuppetModule\PHP($request->request->get('php'));

        $server = $server->getFormatted();
        $apache = $apache->getFormatted();
        $mysql  = $mysql->getFormatted();
        $php    = $php->getFormatted();

        $vagrantFile = $this->twig()->render('Vagrant/Vagrantfile.twig', ['box' => $box]);
        $manifest    = $this->twig()->render('Vagrant/manifest.pp.twig', [
            'server' => $server,
            'apache' => $apache,
            'php'    => $php,
            'mysql'  => $mysql,
        ]);

        $domainFile = new Domain\File(VENDOR_PATH . '/jtreminio/vagrant-puppet-lamp');
        $domainFile->createArchive([
            'vagrantFile'                             => $vagrantFile,
            'manifests/default.pp'                    => $manifest,
            'modules/puphpet/files/dot/.bash_aliases' => $server['bashaliases'],
        ]);
        $domainFile->downloadFile($box['name']);

        return;
    }
}
