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

    /** @var $session Session */
    private $session;

    /** @var $twig \Twig_Environment */
    private $twig;

    /** @var UrlGenerator */
    private $urlGenerator;

    public function __construct(Application $app)
    {
        $this->app = $app;
    }

    /**
     * Sets flash message
     *
     * @param string $type success, error, info, notice
     * @param string $msg Message
     */
    protected function setFlash($type, $msg)
    {
        $this->session()->getFlashBag()->add($type, $msg);
    }

    /**
     * @return Session
     */
    protected function session()
    {
        if (is_null($this->session)) {
            $this->session = $this->app['session'];
        }

        return $this->session;
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

    /**
     * @return UrlGenerator
     */
    protected function urlGenerator()
    {
        if (is_null($this->urlGenerator)) {
            $this->urlGenerator = $this->app['url_generator'];
        }

        return $this->urlGenerator;
    }
}
