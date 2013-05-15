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

        $server['bashaliases'] = str_replace("\r\n", "\n", $server['bashaliases']);
        $server['packages'] = $this->explodeAndQuote($server['packages']);

        if ($key = array_search('python-software-properties', $server['packages']) !== FALSE) {
            unset($server['packages'][$key]);
        }

        $server['bashaliases'] = trim($server['bashaliases']);

        $apache['modules'] = !empty($apache['modules'])
            ? $apache['modules']
            : [];

        foreach ($apache['vhosts'] as $id => $vhost) {
            $apache['vhosts'][$id]['serveraliases'] = $this->explodeAndQuote($apache['vhosts'][$id]['serveraliases']);
            $apache['vhosts'][$id]['envvars'] = $this->explodeAndQuote($apache['vhosts'][$id]['envvars']);
        }

        foreach ($mysql['db'] as $key => $db) {
            if (empty($db['user']) || empty($db['dbname'])) {
                unset($mysql['db'][$key]);
                continue;
            }
        }

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
