<?php

namespace Puphpet\Domain\PuppetModule;

class Server extends PuppetModuleAbstract implements PuppetModuleInterface
{
    /**
     * Return ready to use server array
     *
     * @return array
     */
    public function getFormatted()
    {
        if (empty($this->configuration)) {
            return array();
        }

        $this->formatBashAliases()
             ->formatPackages();

        return $this->configuration;
    }

    /**
     * Submitted .bash_aliases contents
     *
     * @return self
     */
    protected function formatBashAliases()
    {
        $this->configuration['bashaliases'] = !empty($this->configuration['bashaliases'])
            ? trim(str_replace("\r\n", "\n", $this->configuration['bashaliases']))
            : '';

        return $this;
    }

    /**
     * A comma-delimited string of package names
     *
     * @return self
     */
    protected function formatPackages()
    {
        $this->configuration['packages'] = !empty($this->configuration['packages'])
            ? $this->explode($this->configuration['packages'])
            : array();

        $key = array_search('python-software-properties', $this->configuration['packages']);

        // python-software-properties is installed by default, remove to prevent duplicate Puppet function
        if ($key !== FALSE) {
            unset($this->configuration['packages'][$key]);
        }

        return $this;
    }
}
