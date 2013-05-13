<?php

namespace Puphpet;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Silex\ControllerCollection;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session\Session;
use Symfony\Component\Routing\Generator\UrlGenerator;

/**
 * Base controller class
 */
abstract class Controller implements ControllerProviderInterface
{
    /** @var Application */
    protected $app;

    /** @var $twig \Twig_Environment */
    private $twig;

    public function __construct(Application $app)
    {
        $this->app = $app;
    }

    /**
     * @return \Twig_Environment
     */
    protected function twig()
    {
        if (is_null($this->twig)) {
            $this->twig = $this->app['twig'];
        }

        return $this->twig;
    }
}
