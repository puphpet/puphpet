<?php

namespace Puphpet\MainBundle\Twig;

use RandomLib;

class BaseExtension extends \Twig_Extension
{
    /** @var \RandomLib\Factory */
    private $randomLib;

    public function __construct(RandomLib\Factory $randomLib)
    {
        $this->randomLib = $randomLib;
    }

    public function getFunctions()
    {
        return [
            new \Twig_SimpleFunction('mt_rand', [$this, 'mt_rand']),
            new \Twig_SimpleFunction('uniqid', [$this, 'uniqid']),
        ];
    }

    public function getFilters()
    {
        return [
            'str_replace' => new \Twig_Filter_Function([$this, 'str_replace']),
        ];
    }

    public function uniqid()
    {
        $random = $this->randomLib->getLowStrengthGenerator();

        $characters = '0123456789abcdefghijklmnopqrstuvwxyz' .
                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

        return $random->generateString(12, $characters);
    }

    public function mt_rand($min, $max)
    {
        return mt_rand($min, $max);
    }

    public function str_replace($subject, $search, $replace)
    {
        return str_replace($search, $replace, $subject);
    }

    public function getName()
    {
        return 'base_extension';
    }
}
