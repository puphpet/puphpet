<?php

namespace Puphpet\Domain\Compiler\Event;

use Puphpet\Domain\Compiler\Compilation;
use Symfony\Component\EventDispatcher\Event;

class CompilationEvent extends Event
{
    /**
     * @var Compilation
     */
    private $compilation;

    /**
     * @param Compilation $compilation
     */
    public function __construct(Compilation $compilation)
    {
        $this->compilation = $compilation;
    }

    /**
     * @return Compilation
     */
    public function getCompilation()
    {
        return $this->compilation;
    }
}
