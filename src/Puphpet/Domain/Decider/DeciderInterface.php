<?php

namespace Puphpet\Domain\Decider;

interface DeciderInterface
{
    /**
     * Wether something should be executed by given configuration
     *
     * @param array $configuration
     *
     * @return bool
     */
    public function supports(array &$configuration);
}
