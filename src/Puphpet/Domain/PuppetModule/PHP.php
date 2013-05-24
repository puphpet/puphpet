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

        // @TODO all ini settings should be converted to key/value pairs
        // and correct formatting should be done in the template
        foreach ($this->configuration['inilist'] as $type => $iniList) {
            if (is_array($iniList)) {
                $settings = array();
                foreach ($iniList as $key => $value) {
                    $settings[] = $this->formatInitLine($key, $value);
                }
                $this->configuration['inilist'][$type] = $settings;
            } else {
                $this->configuration['inilist'][$type] = $this->formatImplodedInilist($iniList);
            }
        }
    }

    /**
     * Formats all ini values correctly
     *
     * Incoming: 'foo = bar, baz = 123, hello = on'
     * Outgoing: ['foo = "bar"', 'baz = 123', 'hello = on']
     *
     * @param array|null $iniList
     *
     * @return array
     */
    protected function formatImplodedInilist($iniList)
    {
        $lines = $this->explode($iniList);
        foreach ($lines as $i => $line) {
            list($key, $value) = explode('=', $line, 2);
            $lines[$i] = $this->formatInitLine($key, $value);
        }

        return $lines;
    }

    /**
     * Formats a php ini line
     *
     * @param string $key
     * @param mixed  $value
     *
     * @return string
     */
    protected function formatInitLine($key, $value)
    {
        return sprintf('%s = %s', trim($key), $this->quoteIniValue(trim($value)));
    }

    /**
     * Ensures that strings are quoted
     *
     * @param string $value
     *
     * @return string
     */
    protected function quoteIniValue($value)
    {
        // numbers may not be quotes
        if (is_numeric($value)) {
            return $value;
        }

        // ini strings may not be quoted
        if (in_array(strtolower($value), ['on', 'off'])) {
            return $value;
        }

        return '"' . $value . '"';
    }
}
