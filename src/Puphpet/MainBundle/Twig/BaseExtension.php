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
            new \Twig_SimpleFunction('uniqid', [$this, 'uniqid']),
        ];
    }

    public function uniqid()
    {
        $random = $this->randomLib->getLowStrengthGenerator();

        $characters = '0123456789abcdefghijklmnopqrstuvwxyz' .
                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

        return $random->generateString(12, $characters);
    }

    public function getName()
    {
        return 'base_extension';
    }
}
