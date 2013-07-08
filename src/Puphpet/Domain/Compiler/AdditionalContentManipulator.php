<?php

namespace Puphpet\Domain\Compiler;

use Puphpet\Domain\Decider\DeciderInterface;

/**
 * Adds some content at the end of given Compilation
 */
class AdditionalContentManipulator implements ManipulatorInterface
{
    /**
     * @var DeciderInterface
     */
    private $decider;

    /**
     * @var \Twig_Environment
     */
    private $twig;

    /**
     * @var string
     */
    private $template;

    /**
     * @param DeciderInterface  $decider
     * @param \Twig_Environment $twig
     * @param string            $template
     */
    public function __construct(DeciderInterface $decider, \Twig_Environment $twig, $template)
    {
        $this->decider = $decider;
        $this->twig = $twig;
        $this->template = $template;
    }

    /**
     * Runs through assigned template and adds additional
     * rendered content to the Compilation.
     *
     * @param Compilation $compilation
     *
     * @return void
     */
    public function manipulate(Compilation $compilation)
    {
        $additional = $this->twig->render($this->template, $compilation->getConfiguration());

        $compilation->addContent($additional);
    }

    /**
     * Wether the Manipulator supports given Compilation
     *
     * @param Compilation $compilation
     *
     * @return bool
     */
    public function supports(Compilation $compilation)
    {
        $configuration = $compilation->getConfiguration();
        return $this->decider->supports($configuration);
    }
}
