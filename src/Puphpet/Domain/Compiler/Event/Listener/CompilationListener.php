<?php

namespace Puphpet\Domain\Compiler\Event\Listener;

use Puphpet\Domain\Compiler\Event\CompilationEvent;
use Puphpet\Domain\Compiler\ManipulatorInterface;

class CompilationListener
{
    /**
     * @var ManipulatorInterface
     */
    private $manipulator;

    /**
     * @param ManipulatorInterface $manipulator
     */
    public function __construct(ManipulatorInterface $manipulator)
    {
        $this->manipulator = $manipulator;
    }

    public function onCompile(CompilationEvent $event)
    {
        $this->manipulator->manipulate($event->getCompilation());
    }
}
