<?php

namespace PuphpetBundle\Twig;

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
            new \Twig_SimpleFunction('merge_unique', [$this, 'mergeUnique']),
            new \Twig_SimpleFunction('add_available', [$this, 'addAvailable']),
            new \Twig_SimpleFunction('formValue', [$this, 'formValue']),
        ];
    }

    public function getFilters()
    {
        return [
            'str_replace' => new \Twig_SimpleFilter('str_replace', 'str_replace'),
        ];
    }

    public function uniqid($prefix)
    {
        $random = $this->randomLib->getLowStrengthGenerator();

        $characters = '0123456789abcdefghijklmnopqrstuvwxyz';

        return $prefix . $random->generateString(12, $characters);
    }

    public function mt_rand($min, $max)
    {
        return mt_rand($min, $max);
    }

    public function str_replace($subject, $search, $replace)
    {
        return str_replace($search, $replace, $subject);
    }

    public function mergeUnique(array $arr1, array $arr2)
    {
        return array_unique(array_merge($arr1, $arr2));
    }

    public function addAvailable(array $arr1, array $arr2)
    {
        return array_merge($arr1, ['available' => $arr2]);
    }

    public function formValue($value)
    {
        if ($value === false) {
            return 'false';
        }

        if ($value === null) {
            return 'false';
        }

        return $value;
    }

    public function getName()
    {
        return 'base_extension';
    }
}
