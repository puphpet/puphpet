<?php

namespace Puphpet\Domain\PuppetModule;

class PHP extends PuppetModuleAbstract implements PuppetModuleInterface
{
    const MODULE_TYPE_PHP  = 'php';
    const MODULE_TYPE_PEAR = 'pear';
    const MODULE_TYPE_PECL = 'pecl';

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

        $this->formatModules(self::MODULE_TYPE_PHP)
          ->formatModules(self::MODULE_TYPE_PEAR)
          ->formatModules(self::MODULE_TYPE_PECL);

        return $this->php;
    }

    /**
     * Array of module names
     *
     * @param string $key Type of module
     *
     * @return self
     */
    protected function formatModules($key)
    {
        $this->php['modules'][$key] = !empty($this->php['modules'][$key])
          ? array_unique($this->php['modules'][$key])
          : array();

        return $this;
    }

    /**
     * Adds a PHP module to configuration
     *
     * @param string $moduleName
     * @param bool   $start      if set the module will be added at the beginning of the module list
     *                           (by default at the end)
     */
    public function addPhpModule($moduleName, $start = false)
    {
        if (!array_key_exists('modules', $this->php)) {
            $this->php['modules'] = array();
        }

        if (!array_key_exists(self::MODULE_TYPE_PHP, $this->php['modules'])) {
            $this->php['modules'][self::MODULE_TYPE_PHP] = array();
        }

        // adding array at the beginning of the list
        if ($start) {
            $tmp = array($moduleName);
            $this->php['modules'][self::MODULE_TYPE_PHP] = array_merge(
                $tmp,
                $this->php['modules'][self::MODULE_TYPE_PHP]
            );
        } else {
            $this->php['modules'][self::MODULE_TYPE_PHP][] = $moduleName;
        }
    }
}
