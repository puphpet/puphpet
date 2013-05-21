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
use Symfony\Component\HttpFoundation\File\File;

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

    public function createAction(Request $request, Application $app)
    {
        $box = $request->request->get('box');
        $domainFile = $app['domain_file'];
        /**@var $domainFile \Puphpet\Domain\File */

        $webserver = $request->request->get('webserver', 'apache');

        // quick validate webserver
        $webserver = in_array($webserver, ['apache', 'nginx'])? $webserver : 'apache';

        // create array assigned to the template later on
        $ressources = [
            'webserver'   => $webserver,
            'php_service' => $webserver == 'nginx'? 'php5-fpm' : 'apache',
        ];

        // start formatting
        $server = new Domain\PuppetModule\Server($request->request->get('server'));
        $ressources['server'] = $server->getFormatted();

        if ('nginx' == $webserver) {
            $nginx = new Domain\PuppetModule\Nginx($request->request->get('nginx'));
            $ressources['nginx'] = $nginx->getFormatted();
            $domainFile->addModuleSource('nginx', VENDOR_PATH . '/jfryman/puppet-nginx');
        } else {
            $apache = new Domain\PuppetModule\Apache($request->request->get('apache'));
            $ressources['apache'] = $apache->getFormatted();
        }

        $mysql  = new Domain\PuppetModule\MySQL($request->request->get('mysql'));
        $ressources['mysql'] = $mysql->getFormatted();

        $php    = new Domain\PuppetModule\PHP($request->request->get('php'));
        $ressources['php'] = $php->getFormatted();

        $vagrantFile = $this->twig()->render('Vagrant/Vagrantfile.twig', ['box' => $box]);
        $manifest    = $this->twig()->render('Vagrant/manifest.pp.twig', $ressources);

        // creating and building the archive
        $domainFile->createArchive([
            'Vagrantfile'                             => $vagrantFile,
            'manifests/default.pp'                    => $manifest,
            'modules/puphpet/files/dot/.bash_aliases' => $ressources['server']['bashaliases'],
        ]);
        $file = $domainFile->getArchivePath();

        $stream = function () use ($file) {
            readfile($file);
        };

        return $this->app->stream($stream, 200, array(
            'Pragma' => 'public',
            'Expires' => 0,
            'Cache-Control' => 'must-revalidate, post-check=0, pre-check=0',
            'Last-Modified' => gmdate ('D, d M Y H:i:s', filemtime($file)) . ' GMT',
            'Content-Type' => 'application/zip',
            'Content-Length' => filesize($file),
            'Content-Disposition' => 'attachment; filename="'.$box['name'].'.zip"',
            'Content-Transfer-Encoding' => 'binary',
            'Connection' => 'close',
        ));
    }
}
