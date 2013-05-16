<?php

namespace Puphpet\Domain;

use Puphpet\Domain;

class Apache extends Domain
{
    /**
     * @param mixed $modules Array of module names
     * @return array
     */
    public function formatModules($modules)
    {
        return !empty($modules)
            ? $modules
            : [];
    }

    /**
     * @param array $vhosts Vhosts to add
     * @return array
     */
    public function formatVhosts(array $vhosts)
    {
        foreach ($vhosts as $id => $vhost) {
            $vhosts[$id]['serveraliases'] = $this->explodeAndQuote($vhosts[$id]['serveraliases']);
            $vhosts[$id]['envvars']       = $this->explodeAndQuote($vhosts[$id]['envvars']);
        }

        return $vhosts;
    }
}
