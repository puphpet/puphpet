<?php

namespace Puphpet\Domain\Decider;

/**
 * Always pass. Needed if you always have to do something.
 */
class PassDecider implements DeciderInterface
{
    /**
     * Wether something should be executed by given configuration
     *
     * @param array $configuration
     *
     * @return bool
     */
    public function supports(array &$configuration)
    {
        return true;
    }
}
