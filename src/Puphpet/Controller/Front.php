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
            'Front/help.html.twig',
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
        $domainFile = $app['request_file_generator']->generateArchive($request);

        $file = $domainFile->getArchivePath();

        return $this->app->stream(
            function () use ($file) {
                readfile($file);
            },
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
