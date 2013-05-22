<?php

namespace Puphpet\Domain\PuppetModule;

class Apache extends PuppetModuleAbstract implements PuppetModuleInterface
{
    /**
     * Return ready to use Apache array
     *
     * @return array
     */
    public function getFormatted()
    {
        if (empty($this->configuration)) {
            return array();
        }

        $this->formatModules()
            ->formatVhosts();

        return $this->configuration;
    }

    /**
     * Array of module names
     *
     * @return self
     */
    protected function formatModules()
    {
        $this->configuration['modules'] = !empty($this->configuration['modules'])
            ? $this->configuration['modules']
            : array();

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
            $vhosts[$id]['serveraliases'] = !empty($vhosts[$id]['serveraliases'])
                ? $this->explode($vhosts[$id]['serveraliases'])
                : array();

            $vhosts[$id]['envvars'] = !empty($vhosts[$id]['envvars'])
                ? $this->explode($vhosts[$id]['envvars'])
                : array();
        }

        $this->configuration['vhosts'] = $vhosts;

        return $this;
    }
}
