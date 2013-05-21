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
     * Return ready to use PHP array
     *
     * @return array
     */
    public function getFormatted()
    {
        if (empty($this->php)) {
            return array();
        }

        $this->formatModules('php')
            ->formatModules('pear')
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
        $this->php['modules'][$key] = !empty($this->php['modules'][$key])
            ? $this->php['modules'][$key]
            : array();

        return $this;
    }
}
