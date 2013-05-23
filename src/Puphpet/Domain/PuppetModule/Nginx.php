<?php

namespace Puphpet\Domain\PuppetModule;

class Nginx extends PuppetModuleAbstract implements PuppetModuleInterface
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

        $this->formatCommonConfiguration()
            ->formatVhosts();

        return $this->configuration;
    }

    protected function formatCommonConfiguration()
    {
        if (array_key_exists('servername', $this->configuration)) {
            $this->configuration['servername'] = trim($this->configuration['servername']);
        }

        return $this;
    }

    /**
     * Vhosts to add
     *
     * @return self
     */
    protected function formatVhosts()
    {
        if (empty($this->configuration['vhosts'])) {
            $this->configuration['vhosts'] = array();
        }

        $vhosts = $this->configuration['vhosts'];

        foreach ($vhosts as $id => $vhost) {
            $vhosts[$id]['serveraliases'] = empty($vhosts[$id]['serveraliases'])
                ? array()
                : $this->explode($vhosts[$id]['serveraliases']);

            $vhosts[$id]['envvars'] = empty($vhosts[$id]['envvars'])
                ? array()
                : $this->explodeAndMap($vhosts[$id]['envvars']);

            $vhosts[$id]['index_files'] = empty($vhosts[$id]['index_files'])
                ? array()
                : $this->explode($vhosts[$id]['index_files']);
        }

        $this->configuration['vhosts'] = $vhosts;

        return $this;
    }
}
