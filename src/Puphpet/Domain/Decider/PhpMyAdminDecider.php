<?php

namespace Puphpet\Domain\Decider;

/**
 * Always pass. Needed if you always have to do something.
 */
class PhpMyAdminDecider implements DeciderInterface
{
    /**
    * @var string
    */
    private $phpmyadmin;

    /**
    * @param string $phpmyadmin
    */
    public function __construct($phpmyadmin)
    {
        $this->phpmyadmin = $phpmyadmin;
    }

    /**
     * Wether the configuration matches for optional PhpMyAdmin.
     *
     * @param array $configuration
     *
     * @return bool
     */
    public function supports(array &$configuration)
    {
        if (array_key_exists('mysql', $configuration)
            && array_key_exists($this->phpmyadmin, $configuration['mysql'])
        ) {
            return (bool) $configuration['mysql']['phpmyadmin'];
        }

        return false;
    }
}
