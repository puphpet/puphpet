<?php

namespace PuphpetBundle;

use Symfony\Bundle\FrameworkBundle;
use Symfony\Component\HttpFoundation\Session\Session;

abstract class Controller extends FrameworkBundle\Controller\Controller
{
    protected function getSession() : Session
    {
        return $this->get('session');
    }

    protected function getExtensionData(string $extension) : array
    {
        $manager = $this->get('puphpet.extension.manager');

        return $manager->getExtensionAvailableData($extension);
    }
}
