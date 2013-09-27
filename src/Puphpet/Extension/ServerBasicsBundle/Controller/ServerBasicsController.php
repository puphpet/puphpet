<?php

namespace Puphpet\Extension\ServerBasicsBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ServerBasicsController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionServerBasicsBundle:form:ServerBasics.html.twig', [
            'server' => $data,
        ]);
    }
}
