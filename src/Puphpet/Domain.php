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
        return array_map(function($value) {
                $value = str_replace("'", '', str_replace('"', '', $value));
                return "'{$value}'";
            },
            $values
        );
    }
}
