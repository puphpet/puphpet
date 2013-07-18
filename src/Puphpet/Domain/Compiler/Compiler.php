<?php

namespace Puphpet\Domain\Compiler;

use Puphpet\Domain\Compiler\Event\CompilationEvent;
use Symfony\Component\EventDispatcher\EventDispatcherInterface;

/**
 * Builds the content of Vagrant/Puppet files.
 */
class Compiler
{
    /**
     * @var EventDispatcherInterface
     */
    private $eventDispatcher;

    /**
     * @var \Twig_Environment
     */
    private $twig;

    /**
     * @var string
     */
    private $template;

    /**
     * @var string
     */
    private $identifier;

    /**
     * @param EventDispatcherInterface $eventDispatcher
     * @param \Twig_Environment        $twig
     * @param string                   $template
     * @param string                   $identifier
     */
    public function __construct(
        EventDispatcherInterface $eventDispatcher,
        \Twig_Environment $twig,
        $template,
        $identifier
    ) {
        $this->eventDispatcher = $eventDispatcher;
        $this->twig = $twig;
        $this->template = $template;
        $this->identifier = $identifier;
    }

    /**
     * Override template location
     *
     * @param string $template
     * @return self
     */
    public function setTemplate($template)
    {
        $this->template = $template;

        return $this;
    }

    /**
     * @param array $configuration formatted configuration
     *
     * @return string
     */
    public function compile(array $configuration)
    {
        // @TODO fire a "start" event so that each system could hook in
        // and populate the compilation on their own
        $rendered = $this->twig->render($this->template, $configuration);

        // fire the finish event so someone could add sth to the compilation
        $compilation = new Compilation($rendered, $configuration);
        $event = new CompilationEvent($compilation);
        $eventName = 'compile.' . $this->identifier . '.finish';
        $this->eventDispatcher->dispatch($eventName, $event);

        return $compilation->getContent();
    }
}
