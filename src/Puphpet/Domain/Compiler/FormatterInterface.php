<?php

namespace Puphpet\Domain\Compiler;

/**
 * Interface for all formatters which are used for building up Vagrant/Puppet files.
 */
interface FormatterInterface
{
    /**
     * Builds and returns formatted configuration
     * which could be used within templates
     *
     * @return string
     */
    public function format();
}
