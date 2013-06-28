<?php

namespace Puphpet\Controller;

use Puphpet\Controller;

use Silex\Application;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\Request;

class Quickstart extends Controller
{
    public function connect(Application $app)
    {
        /** @var $controllers ControllerCollection */
        $controllers = $app['controllers_factory'];

        $controllers->get('/{edition}', [$this, 'startAction'])
            ->bind('quickstart');

        $controllers->post('/{edition}', [$this, 'createAction'])
            ->bind('quickstart_create');

        return $controllers;
    }

    public function startAction(Application $app, $edition)
    {
        $edition = $app['edition_provider']->provide($edition);
        /**@var $edition \Puphpet\Domain\Configuration\Edition*/

        return $this->twig()->render(
            $edition->get('template'),
            [
                'currentPage' => 'quickstart',
                'edition'     => $edition,
            ]
        );
    }

    public function createAction(Request $request, Application $app, $edition)
    {
        $edition = $app['edition_provider']->provide($edition);
        /**@var $edition \Puphpet\Domain\Configuration\Edition*/

        // fetch the configured builder from services
        $serviceName = $edition->get('builder');
        if (!$serviceName) {
            throw new \InvalidArgumentException('The option "builder" is not configured for given Edition.');
        }
        $configurationBuilder = $app[$serviceName];

        // each edition has its own configuration builder
        // which builds the huge array needed for archive generation
        $configuration = $configurationBuilder->build($edition, $request->request->all());

        $domainFile = $app['configuration_file_generator']->generateArchive($configuration);

        $file = $domainFile->getArchivePath();

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
