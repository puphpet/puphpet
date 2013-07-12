<?php

namespace Puphpet\Controller;

use Puphpet\Controller;

use Puphpet\Domain;
use Puphpet\Domain\Configuration\Configuration;
use Silex\Application;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

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

        $controllers->get('/manifest', [$this, 'manifestAction'])
            ->bind('manifest');

        $controllers->get('/about', [$this, 'aboutAction'])
            ->bind('about');

        $controllers->get('/help', [$this, 'helpAction'])
            ->bind('help');

        $controllers->get('/github-btn', [$this, 'githubbtnAction'])
            ->bind('github-btn');

        return $controllers;
    }

    public function indexAction(Request $request, Application $app)
    {
        $edition = $app['edition_provider']->provide($request->query->get('edition', 'default'));

        return $this->twig()->render(
            'Front/index.html.twig',
            [
                'currentPage' => 'home',
                'timezones'   => \DateTimeZone::listIdentifiers(),
                'edition'     => $edition,
            ]
        );
    }

    public function aboutAction()
    {
        return $this->twig()->render(
            'Front/one-column.html.twig',
            [
                'currentPage' => 'about',
                'markdown'    => $this->parseMarkdown('Front/Markdown/about.md')
            ]
        );
    }

    public function helpAction()
    {
        return $this->twig()->render(
            'Front/one-column.html.twig',
            [
                'currentPage' => 'help',
                'markdown'    => $this->parseMarkdown('Front/Markdown/help.md')
            ]
        );
    }

    public function githubbtnAction()
    {
        return $this->twig()->render('Front/github-btn.html.twig');
    }

    public function createAction(Request $request, Application $app)
    {
        /** @var $domainFile \Puphpet\Domain\File */
        $configuration = new Configuration($request->request->all());
        $domainFile = $app['configuration_file_generator']->generateArchive($configuration);

        $file = $domainFile->getArchiveFile();

        return $this->app->sendFile(
            $file,
            200,
            [
                'Pragma'                    => 'public',
                'Expires'                   => 0,
                'Cache-Control'             => 'must-revalidate, post-check=0, pre-check=0',
                'Last-Modified'             => gmdate('D, d M Y H:i:s', filemtime($file)) . ' GMT',
                'Content-Type'              => 'application/zip',
                'Content-Length'            => filesize($file),
                'Content-Disposition'       => 'attachment; filename="' . $domainFile->getName() . '"',
                'Content-Transfer-Encoding' => 'binary',
                'Connection'                => 'close',
            ]
        );
    }

    /**
     * Dumps out only the compiled manifest.
     * Needed in preparation for RSpec testing
     *
     * @param Request     $request
     * @param Application $app
     */
    public function manifestAction(Request $request, Application $app)
    {
        $compiler = $app['manifest_compiler'];

        $manifestConfiguration = $this->getConfiguration();

        $manifest = $compiler->compile($manifestConfiguration);

        return new Response($manifest, 200, [
           'Content-Type' => 'text/plain'
        ]);
    }

    private function getConfiguration()
    {
        return [
            'webserver'   => 'apache',
            'database'    => 'mysql',
            'php_service' => 'apache',
            'server'      => ['packages' => ['foo', 'bar']],
            'apache'      => [
                'vhosts'  => [
                    [
                        'servername'    => 'myserver',
                        'serveraliases' => array(),
                        'envvars'       => array(),
                        'docroot'       => '/var/www',
                        'port'          => 80,
                    ]
                ],
                'modules' => ['foo', 'bar'],
            ],
            'php'         => [
                'version' => 'php55',
                'modules' => [
                    'php'      => ['php5-cli'],
                    'pear'     => ['installed' => true],
                    'pecl'     => array(),
                    'composer' => ['installed' => true],
                    'xdebug'   => ['installed' => true],
                    'xhprof'   => ['installed' => true],
                ],
                'inilist' => [
                    'php'    => [
                        'date.timezone = "America/Chicago"',
                    ],
                    'custom' => [
                        'display_errors = On',
                        'error_reporting = 1'
                    ],
                    'xdebug' => [
                        'xdebug.default_enable = 1',
                        'xdebug.remote_autostart = 0',
                        'xdebug.remote_connect_back = 1',
                    ]
                ],
            ],
            'mysql'       => [
                'root'       => 'rootpwd',
                'phpmyadmin' => false,
                'dbuser'     => [
                    [
                        'dbname'     => 'test_dbname',
                        'privileges' => [],
                        'user'       => 'test_user',
                        'password'   => 'test_password',
                        'host'       => 'test_host',
                    ]
                ]
            ]
        ];
    }
}
