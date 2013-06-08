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

    private $markdown;
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

    /**
     * @return \dflydev\markdown\MarkdownParser
     */
    protected function markdown()
    {
        if (is_null($this->markdown)) {
            $this->markdown = $this->app['markdown'];
        }

        return $this->markdown;
    }

    /**
     * Returns raw, unparsed source of a file in View folder
     *
     * @param string $path Path to template file
     * @return string
     */
    protected function rawTemplate($path)
    {
        return $this->twig()->getLoader()->getSource($path);
    }

    protected function parseMarkdown($path)
    {
        return $this->markdown()->transformMarkdown($this->rawTemplate($path));
    }
}
