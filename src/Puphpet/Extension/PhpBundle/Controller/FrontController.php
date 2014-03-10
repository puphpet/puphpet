<?php

namespace Puphpet\Extension\PhpBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionPhpBundle:form:Php.html.twig', [
            'php'   => $data,
            'extra' => $extra,
        ]);
    }
}
