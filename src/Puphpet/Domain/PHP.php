<?php

namespace Puphpet\Domain;

use Puphpet\Domain;

class PHP extends Domain
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
}
