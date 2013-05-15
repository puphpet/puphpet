<?php

namespace Puphpet;

class Domain
{
    /**
     * @param mixed $values
     * @return array
     */
    public function explodeAndQuote($values)
    {
        $values = !empty($values) ? explode(',', $values) : [];

        return $this->quoteArray($values);
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
