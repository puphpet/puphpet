<?php

namespace Puphpet;

class Domain
{
    protected function explodeAndQuote($values)
    {
        $values = !empty($values) ? explode(',', $values) : [];

        $values = array_map(
            function($value)
            {
                $value = str_replace("'", '', str_replace('"', '', $value));
                return "'{$value}'";
            },
            $values
        );

        return $values;
    }
}
