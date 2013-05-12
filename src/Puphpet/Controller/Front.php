<?php

namespace Puphpet\Controller;

use Puphpet\Controller;

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
        /** @var $controllers ControllerCollection creates a new controller based on the default route */
        $controllers = $app['controllers_factory'];

        $controllers->get('/', [$this, 'indexAction'])
             ->bind('homepage');

        $controllers->post('/create', [$this, 'createAction'])
             ->bind('create');

        return $controllers;
    }

    public function indexAction()
    {
        return $this->twig()->render('Front/index.html.twig');
    }

    public function createAction(Request $request)
    {
        $box    = $request->get('box');
        $server = $request->get('server');
        $apache = $request->get('apache');
        $php    = $request->get('php');
        $mysql  = $request->get('mysql');

        $server['packages'] = $this->explodeAndQuote($server['packages']);

        // TODO: Handle user-defined bashaliases correctly. Right now it's ignoring this and using file
        $server['bashaliases'] = trim($server['bashaliases']);

        $apache['modules'] = !empty($apache['modules'])
            ? $apache['modules']
            : [];

        foreach ($apache['vhosts'] as $id => $vhost) {
            $apache['vhosts'][$id]['serveraliases'] = $this->explodeAndQuote($apache['vhosts'][$id]['serveraliases']);
            $apache['vhosts'][$id]['envvars'] = $this->explodeAndQuote($apache['vhosts'][$id]['envvars']);
        }

        $php['modules'] = $this->explodeAndQuote($php['modules']);
        $php['pearmodules'] = $this->explodeAndQuote($php['pearmodules']);
        $php['pecl'] = $this->explodeAndQuote($php['pecl']);

        $vagrantFile = $this->twig()->render('Vagrant/Vagrantfile.twig', ['box' => $box]);
        $manifest    = $this->twig()->render('Vagrant/manifest.twig',
            [
                'server' => $server,
                'apache' => $apache,
                'php'    => $php,
                'mysql'  => $mysql,
            ]
        );

        $zip = new \ZipArchive;
        $filename = tempnam(sys_get_temp_dir(), uniqid());
        $opened = $zip->open($filename);

        if ($opened === true) {
            $this->addDir($zip, __DIR__ . '/../repo');
            $zip->addFromString('Vagrantfile', $vagrantFile);
            $zip->addFromString('manifests/default.pp', $manifest);
            $zip->addFromString('modules/puphpet/files/dot/.bash_aliases', $server['bashaliases']);

            $zip->close();

            header('Pragma: public'); 	// required
            header('Expires: 0');		// no cache
            header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
            header('Last-Modified: '.gmdate ('D, d M Y H:i:s', filemtime ($filename)).' GMT');
            header('Cache-Control: private',false);
            header('Content-Type: application/zip');
            header('Content-Disposition: attachment; filename="puphpet.zip"');
            header('Content-Transfer-Encoding: binary');
            header('Content-Length: ' . filesize($filename));	// provide file size
            header('Connection: close');
            readfile($filename);		// push it out
            exit();
        }
    }

    protected function explodeAndQuote($values)
    {
        $values = !empty($values) ? explode(',', $values) : [];

        $values = array_map(
            function($value) {
                $value = str_replace("'", '', str_replace('"', '', $value));
                return "'{$value}'";
            },
            $values
        );

        return $values;
    }

    public function addDir(\ZipArchive $zip, $path) {
        $zip->addEmptyDir($path);

        $nodes = glob($path . '/*');
        foreach ($nodes as $node) {
            if (is_dir($node)) {
                $this->addDir($zip, $node);
            } elseif (is_file($node))  {
                $zip->addFile($node);
            }
        }
    }
}
