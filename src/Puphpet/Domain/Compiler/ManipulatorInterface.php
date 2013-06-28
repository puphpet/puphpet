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

    /**
     * Returns wether the Manipulator has to
     * manipulate the given Compilation
     *
     * @param Compilation $compilation
     *
     * @return bool
     */
    public function supports(Compilation $compilation);
}
