<?php

namespace Puphpet\Domain\PuppetModule;

class Server extends PuppetModuleAbstract implements PuppetModuleInterface
{
    protected $server;

    public function __construct($server)
    {
        $this->server = is_array($server) ? $server : array();
    }

    /**
     * Return ready to use server array
     *
     * @return array
     */
    public function getFormatted()
    {
        if (empty($this->server)) {
            return array();
        }

        $this->formatBashAliases()
             ->formatPackages();

        return $this->server;
    }

    /**
     * Submitted .bash_aliases contents
     *
     * @return self
     */
    protected function formatBashAliases()
    {
        $this->server['bashaliases'] = !empty($this->server['bashaliases'])
            ? trim(str_replace("\r\n", "\n", $this->server['bashaliases']))
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
        $this->server['packages'] = !empty($this->server['packages'])
            ? $this->explode($this->server['packages'])
            : array();

        $key = array_search('python-software-properties', $this->server['packages']);

        // python-software-properties is installed by default, remove to prevent duplicate Puppet function
        if ($key !== FALSE) {
            unset($this->server['packages'][$key]);
        }

        return $this;
    }
}
