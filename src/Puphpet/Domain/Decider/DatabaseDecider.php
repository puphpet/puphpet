<?php

namespace Puphpet\Domain\Decider;

/**
 * Always pass. Needed if you always have to do something.
 */
class DatabaseDecider implements DeciderInterface
{
    /**
     * @var string
     */
    private $database;

    /**
     * @param string $database
     */
    public function __construct($database)
    {
        $this->database = $database;
    }

    /**
     * Wether the configuration matches for required database.
     *
     * @param array $configuration
     *
     * @return bool
     */
    public function supports(array &$configuration)
    {
        if (array_key_exists('database', $configuration) && $this->database == $configuration['database']) {
            if (array_key_exists($this->database, $configuration) && is_array($configuration[$this->database])) {
                return true;
            }
        }

        return false;
    }
}
