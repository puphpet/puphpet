<?php

namespace Puphpet\Domain\Compiler\Event\Listener;

use Puphpet\Domain\Compiler\Event\CompilationEvent;
use Puphpet\Domain\Compiler\ManipulatorInterface;

/**
 * Forwards the Compilation fired via event
 * to assigned manipulators.
 */
class CompilationListener
{
    /**
     * @var array[] ManipulatorInterface
     */
    private $manipulators;

    /**
     * @param array $manipulator
     */
    public function __construct(array $manipulators = array())
    {
        $this->manipulators = $manipulators;
    }

    // ManipulatorInterface
    public function onCompile(CompilationEvent $event)
    {
        $compilation = $event->getCompilation();

        foreach ($this->manipulators as $manipulator) {
            /**@var $manipulator \Puphpet\Domain\Compiler\ManipulatorInterface*/
            if ($manipulator->supports($compilation)) {
                $manipulator->manipulate($compilation);
            }
        }
    }
}
