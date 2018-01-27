<?php

namespace PuphpetBundle\Helper;

abstract class Strings
{
    public static function randString($length) : string
    {
        $characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

        $charactersLength = strlen($characters);
        $randomString = '';

        for ($i = 0; $i < $length; $i++) {
            $randomString .= $characters[rand(0, $charactersLength - 1)];
        }

        return $randomString;
    }
}
