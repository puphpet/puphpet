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
        $server = $request->get('server');
        $apache = $request->get('apache');
        $php    = $request->get('php');
        $mysql  = $request->get('mysql');

        $domainServer = new Domain\Server;
        $domainApache = new Domain\Apache;
        $domainMySQL  = new Domain\MySQL;

        $server['bashaliases'] = $domainServer->formatBashAliases($server['bashaliases']);
        $server['packages']    = $domainServer->formatPackages($server['packages']);

        $apache['modules'] = $domainApache->formatModules($apache['modules']);
        $apache['vhosts']  = $domainApache->formatVhosts($apache['vhosts']);

        $mysql['db'] = $domainMySQL->removeIncomplete($mysql['db']);

        $vagrantFile = $this->twig()->render('Vagrant/Vagrantfile.twig', ['box' => $box]);
        $manifest    = $this->twig()->render('Vagrant/manifest.twig',
            [
                'server' => $server,
                'apache' => $apache,
                'php'    => $php,
                'mysql'  => $mysql,
            ]
        );

        $tmpDir = sys_get_temp_dir();
        $tmpFolder = uniqid();
        $source = __DIR__ . '/../repo';
        $filename = tempnam(sys_get_temp_dir(), uniqid()) . '.zip';

        shell_exec("cp -r {$source} {$tmpDir}/{$tmpFolder}");
        file_put_contents("{$tmpDir}/{$tmpFolder}/Vagrantfile", $vagrantFile);
        file_put_contents("{$tmpDir}/{$tmpFolder}/manifests/default.pp", $manifest);
        file_put_contents("{$tmpDir}/{$tmpFolder}/modules/puphpet/files/dot/.bash_aliases", $server['bashaliases']);
        shell_exec("cd {$tmpDir}/{$tmpFolder} && zip -r {$filename} * -x */.git\*");

        header('Pragma: public');
        header('Expires: 0');
        header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
        header('Last-Modified: ' . gmdate ('D, d M Y H:i:s', filemtime($filename)) . ' GMT');
        header('Cache-Control: private', false);
        header('Content-Type: application/zip');
        header('Content-Length: ' . filesize($filename));
        header('Content-Disposition: attachment; filename="puphpet.zip"');
        header('Content-Transfer-Encoding: binary');
        header('Connection: close');
        readfile($filename);
        exit();
    }
}
