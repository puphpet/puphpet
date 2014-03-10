<?php

namespace Puphpet\Extension\ServerBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionServerBundle:form:Server.html.twig', [
            'server' => $data,
            'extra'  => $extra,
        ]);
    }
}
