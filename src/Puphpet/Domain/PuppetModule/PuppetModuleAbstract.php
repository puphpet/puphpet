<?php

namespace Puphpet\Domain\PuppetModule;

abstract class PuppetModuleAbstract
{
    /**
     * @var array
     */
    protected $configuration;

    public function __construct($configuration = array())
    {
        $this->configuration = is_array($configuration) ? $configuration : array();
    }

    /**
     * Sets the raw unformatted configuration
     */
    public function setConfiguration(array $configuration)
    {
        $this->configuration = $configuration;
    }

    /**
     * Explodes a given list, trims all elements and removes empty entries
     *
     * @param  array $values
     * @return array
     */
    protected function explode($values)
    {
        if (empty($values)) {
            return array();
        }

        // already exploded array given!?
        if (is_array($values)) {
            return $values;
        }

        $result = array();
        foreach (explode(',', $values) as $value) {
            $val = trim($value);
            // remove all empty elements
            if ($val !== '') {
                $result[] = $val;
            }
        }

        return $result;
    }

    /**
     * Explodes given values and generates key-value map
     *
     * Example:
     * "FOO BAR,Hello World" -> ['FOO' => 'BAR, 'Hello' => 'World']
     *
     * @param  string $values
     * @param  string $seperator
     * @return array
     */
    protected function explodeAndMap($values, $seperator = ' ')
    {
        $result = array();
        foreach ($this->explode($values) as $line) {
            $split = explode($seperator, $line, 2);
            // do we have sth like "Foo Bar"? If not, skip it!
            if (count($split) == 2) {
                $result[$split[0]] = trim($split[1]);
            }
        }

        return $result;
    }
}
