<?php

namespace Puphpet\Domain\PuppetModule;

abstract class PuppetModuleAbstract
{
    /**
     * @param mixed $values
     * @return array
     */
    protected function explodeAndQuote($values)
    {
        $values = !empty($values) ? explode(',', $values) : array();

        return $this->quoteArray($values);
    }

    /**
     * Explodes a given list, trims all elements and removes empty entries
     *
     * @param array $values
     *
     * @return array
     */
    protected function explode($values)
    {
        if (empty($values)) {
            return [];
        }

        $result = [];
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
     * @param string $values
     * @param string $seperator
     *
     * @return array
     */
    protected function explodeAndMap($values, $seperator = ' ')
    {
        $result = [];
        foreach ($this->explode($values) as $line) {
            $split = explode($seperator, $line, 2);
            // do we have sth like "Foo Bar"? If not, skip it!
            if (2 == count($split)) {
                $result[$split[0]] = trim($split[1]);
            }
        };

        return $result;
    }

    /**
     * @param $values
     * @return array
     */
    protected function quoteArray($values)
    {
        foreach ($values as $id => $value) {
            $value = trim($value);

            if ($value == '') {
                unset($values[$id]);
                continue;
            }

            $value = str_replace("'", '', str_replace('"', '', $value));

            $values[$id] = "'{$value}'";
        }

        return $values;
    }
}
