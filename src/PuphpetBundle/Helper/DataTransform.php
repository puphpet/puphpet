<?php

namespace PuphpetBundle\Helper;

abstract class DataTransform
{
    /**
     * Normalize linebreaks in string.
     *
     * @param string $string
     * @return string
     */
    public static function normalizeLineBreaks(string $string) : string
    {
        $string = str_replace("\r\n", "\n", $string);
        $string = str_replace("\n\r", "\n", $string);

        $string = str_replace('\r\n', '\n', $string);
        $string = str_replace('\n\r', '\n', $string);

        return $string;
    }
}
