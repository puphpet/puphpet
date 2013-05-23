<?php

namespace Puphpet\Domain\PuppetModule;

class PHP extends PuppetModuleAbstract implements PuppetModuleInterface
{
    const MODULE_TYPE_PHP = 'php';
    const MODULE_TYPE_PEAR = 'pear';
    const MODULE_TYPE_PECL = 'pecl';

    /**
     * Return ready to use PHP array
     *
     * @return array
     */
    public function getFormatted()
    {
        if (empty($this->configuration)) {
            return array();
        }

        $this->formatModules(self::MODULE_TYPE_PHP)
            ->formatModules(self::MODULE_TYPE_PEAR)
            ->formatModules(self::MODULE_TYPE_PECL)
            ->formatIni();

        return $this->configuration;
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
        $this->configuration['modules'][$key] = !empty($this->configuration['modules'][$key])
            ? array_unique($this->configuration['modules'][$key])
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
        if (!array_key_exists('modules', $this->configuration)) {
            $this->configuration['modules'] = array();
        }

        if (!array_key_exists(self::MODULE_TYPE_PHP, $this->configuration['modules'])) {
            $this->configuration['modules'][self::MODULE_TYPE_PHP] = array();
        }

        // adding array at the beginning of the list
        if ($start) {
            $tmp = array($moduleName);
            $this->configuration['modules'][self::MODULE_TYPE_PHP] = array_merge(
                $tmp,
                $this->configuration['modules'][self::MODULE_TYPE_PHP]
            );
        } else {
            $this->configuration['modules'][self::MODULE_TYPE_PHP][] = $moduleName;
        }
    }

    protected function formatIni()
    {
        if (empty($this->configuration['inilist'])) {
            $this->configuration['inilist'] = array();

            return;
        }

        foreach ($this->configuration['inilist'] as $type => $iniList) {
            $this->configuration['inilist'][$type] = $this->explode($iniList);
        }
    }
}
