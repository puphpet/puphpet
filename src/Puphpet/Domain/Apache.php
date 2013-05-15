<?php

namespace Puphpet\Domain;

use Puphpet\Domain;

class Apache extends Domain
{
    public function formatModules($modules)
    {
        return !empty($modules)
            ? $modules
            : [];
    }

    public function formatVhosts($vhosts)
    {
        foreach ($vhosts as $id => $vhost) {
            $vhosts[$id]['serveraliases'] = $this->explodeAndQuote($vhosts[$id]['serveraliases']);
            $vhosts[$id]['envvars']       = $this->explodeAndQuote($vhosts[$id]['envvars']);
        }

        return $vhosts;
    }
}
