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

        $controllers->get('/about', [$this, 'aboutAction'])
            ->bind('about');

        $controllers->get('/help', [$this, 'helpAction'])
            ->bind('help');

        $controllers->get('/github-btn', [$this, 'githubbtnAction'])
            ->bind('github-btn');

        $controllers->post('/githubContributors', [$this, 'githubContributorsAction'])
            ->bind('github-contributors');

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

    public function githubContributorsAction(Request $request, Application $app)
    {
        return $this->twig()->render(
            'Front/githubContributors.html.twig',
            ['contributors' => $request->get('contributors')]
        );
    }

    public function createAction(Request $request, Application $app)
    {
        $configuration = $app['configuration_builder']->build($request->request->all());
        /** @var $domainFile \Puphpet\Domain\File */
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
}
