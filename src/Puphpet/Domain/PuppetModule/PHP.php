<?php

namespace Puphpet\Domain\PuppetModule;

class PHP extends PuppetModuleAbstract implements PuppetModuleInterface
{
    protected $php;

    public function __construct($php)
    {
        $this->php = is_array($php) ? $php : array();
    }

    /**
     * Return ready to use server array
     *
     * @return array
     */
    public function getFormatted()
    {
        if (empty($this->php)) {
            return array();
        }

        $this->formatModules('modules')
             ->formatModules('pearmodules')
             ->formatModules('pecl');

        return $this->php;
    }

    /**
     * Array of module names
     *
     * @param string $key Type of module
     * @return self
     */
    protected function formatModules($key)
    {
        $this->php[$key] = !empty($this->php[$key])
            ? $this->php[$key]
            : array();

        return $this;
    }
}
