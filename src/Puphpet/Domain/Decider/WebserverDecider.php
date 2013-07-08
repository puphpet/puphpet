<?php

namespace Puphpet\Domain\Decider;

/**
 * Decider for a webserver.
 */
class WebserverDecider implements DeciderInterface
{
    /**
     * @var string
     */
    private $webserver;

    /**
     * @param string $webserver the webserver's identifier
     */
    public function __construct($webserver)
    {
        $this->webserver = $webserver;
    }
    /**
     * Wether the configuration matches for required webserver.
     *
     * @param array $configuration
     *
     * @return bool
     */
    public function supports(array &$configuration)
    {
        if (array_key_exists('webserver', $configuration) && $this->webserver == $configuration['webserver']) {
            if (array_key_exists($this->webserver, $configuration) && is_array($configuration[$this->webserver])) {
                return true;
            }
        }

        return false;
    }
}
