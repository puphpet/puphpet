<?php

namespace Puphpet\Domain\PuppetModule;

class Passthru extends PuppetModuleAbstract implements PuppetModuleInterface
{
    /**
     * Return ready to use Nginx array
     *
     * @return array
     */
    public function getFormatted()
    {
        if (empty($this->configuration)) {
            return array();
        }

        return $this->configuration;
    }
}
