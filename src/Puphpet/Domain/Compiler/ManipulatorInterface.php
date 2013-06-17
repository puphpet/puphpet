<?php

namespace Puphpet\Domain\Compiler;

interface ManipulatorInterface
{
    /**
     * Manipulates given Compilation
     *
     * @param Compilation $compilation
     *
     * @return void
     */
    public function manipulate(Compilation $compilation);
}
