<?php

namespace Puphpet\Domain\Compiler;

/**
 * Builds the content of Vagrant/Puppet files.
 */
class Compiler
{
    /**
     * @var \Twig_Environment
     */
    private $twig;

    /**
     * @var string
     */
    private $template;

    /**
     * @param \Twig_Environment $twig
     * @param string            $template
     */
    public function __construct(\Twig_Environment $twig, $template)
    {
        $this->twig = $twig;
        $this->template = $template;
    }

    /**
     * @param array $configuration formatted configuration
     *
     * @return string
     */
    public function compile(array $configuration)
    {
        return $this->twig->render($this->template, $configuration);
    }
}