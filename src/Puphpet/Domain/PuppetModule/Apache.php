<?php

namespace Puphpet\Domain\PuppetModule;

class Apache extends PuppetModuleAbstract implements PuppetModuleInterface
{
    protected $apache;

    public function __construct($apache)
    {
        $this->apache = is_array($apache) ? $apache : array();
    }

    /**
     * Return ready to use Apache array
     *
     * @return array
     */
    public function getFormatted()
    {
        if (empty($this->apache)) {
            return array();
        }

        $this->formatModules()
            ->formatVhosts();

        return $this->apache;
    }

    /**
     * Array of module names
     *
     * @return self
     */
    protected function formatModules()
    {
        $this->apache['modules'] = !empty($this->apache['modules'])
            ? $this->apache['modules']
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
        if (empty($this->apache['vhosts'])) {
            $this->apache['vhosts'] = array();
        }

        $vhosts = $this->apache['vhosts'];

        foreach ($vhosts as $id => $vhost) {
            $vhosts[$id]['serveraliases'] = !empty($vhosts[$id]['serveraliases'])
                ? $this->explode($vhosts[$id]['serveraliases'])
                : array();

            $vhosts[$id]['envvars']       = !empty($vhosts[$id]['envvars'])
                ? $this->explode($vhosts[$id]['envvars'])
                : array();
        }

        $this->apache['vhosts'] = $vhosts;

        return $this;
    }
}
