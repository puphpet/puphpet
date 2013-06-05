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

        $controllers->get('/github-btn', [$this, 'githubbtnAction'])
            ->bind('github-btn');

        return $controllers;
    }

    public function indexAction(Request $request, Application $app)
    {
        $editionName = $request->query->get('edition', 'default');

        $availableEditions = $app['editions'];

        // validate edition name
        // use fallback if invalid edition name is requested (better than throwing any error)
        if (!array_key_exists($editionName, $availableEditions)) {
            $editionName = $app['edition_default'];
        }

        // fill the edition entity with requested configuration
        /**@var $edition Domain\Configuration\Edition */
        $edition = $app['edition'];
        $edition->setConfiguration($availableEditions[$editionName]);

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

    public function githubbtnAction()
    {
        return $this->twig()->render('Front/github-btn.html.twig');
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

        // build Vagrantfile
        $box = $request->request->get('box');
        $boxConfiguration = ['box' => $box];
        $vagrantConfiguration = array_merge($boxConfiguration, ['mysql' => $manifestConfiguration['mysql']]);
        $vagrantFile = $this->twig()->render('Vagrant/Vagrantfile.twig', $vagrantConfiguration);

        /**@var $domainFile Domain\File build the archive */
        $domainFile = $app['domain_file'];

        // configure the domain file
        $app['domain_file_configurator']->configure($domainFile, $manifestConfiguration);

        $readme = $app['readme_compiler']->compile(array_merge($manifestConfiguration, $boxConfiguration));

        //@TODO adding/replacing files to the archive could be done in configurators
        //@TODO as soon as the domain file supports adding single files
        // creating and building the archive
        $domainFile->createArchive(
            [
                'README'                                  => $readme,
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
