<?php

namespace Puphpet\Domain\Configuration;

use Symfony\Component\PropertyAccess\PropertyAccess;

/**
 * Proxy for retrieving PropertyAccessor (needed for better testability)
 */
class PropertyAccessProvider
{
    /**
     * @return \Symfony\Component\PropertyAccess\PropertyAccessor
     */
    public function provide()
    {
        return PropertyAccess::getPropertyAccessor();
    }

}
