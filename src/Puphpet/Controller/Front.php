<?php

namespace Puphpet\Controller;

use Puphpet\Controller;

use Puphpet\Domain;
use Silex\Application;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;

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
        /** @var Domain\Compiler\Manifest\RequestFormatter $formatter build puppet manifest */
        $formatter = $app['manifest_request_formatter'];
        $formatter->bindRequest($request);
        $manifestConfiguration = $formatter->format();

        /** @var Domain\Compiler\Compiler $manifestCompiler */
        $manifestCompiler = $app['manifest_compiler'];
        $manifest = $manifestCompiler->compile($manifestConfiguration);

        $webserver = $manifestConfiguration['webserver'];
        $database = $manifestConfiguration['database'];

        // build Vagrantfile
        $box = $request->request->get('box');
        $vagrantFile = $this->twig()->render('Vagrant/Vagrantfile.twig', ['box' => $box]);

        /**@var $domainFile Domain\File build the archive */
        $domainFile = $app['domain_file'];

        if ('nginx' == $webserver) {
            $domainFile->addModuleSource('nginx', VENDOR_PATH . '/jfryman/puppet-nginx');
        }

        if ('postgresql' == $database) {
            $domainFile->addModuleSource('postgresql', VENDOR_PATH . '/michaelperrin/puppetlabs-postgresql');
        }

        // creating and building the archive
        $domainFile->createArchive(
            [
                'Vagrantfile'                             => $vagrantFile,
                'manifests/default.pp'                    => $manifest,
                'modules/puphpet/files/dot/.bash_aliases' => $manifestConfiguration['server']['bashaliases'],
            ]
        );
        $file = $domainFile->getArchivePath();

        $stream = function () use ($file) {
            readfile($file);
        };

        return $this->app->stream(
            $stream,
            200,
            [
                'Pragma'                    => 'public',
                'Expires'                   => 0,
                'Cache-Control'             => 'must-revalidate, post-check=0, pre-check=0',
                'Last-Modified'             => gmdate('D, d M Y H:i:s', filemtime($file)) . ' GMT',
                'Content-Type'              => 'application/zip',
                'Content-Length'            => filesize($file),
                'Content-Disposition'       => 'attachment; filename="' . $box['name'] . '.zip"',
                'Content-Transfer-Encoding' => 'binary',
                'Connection'                => 'close',
            ]
        );
    }
}
