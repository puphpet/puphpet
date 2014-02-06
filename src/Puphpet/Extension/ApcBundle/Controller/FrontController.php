<?php

namespace Puphpet\Extension\ApcBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionApcBundle:form:Apc.html.twig', [
            'apc' => $data,
        ]);
    }
}
