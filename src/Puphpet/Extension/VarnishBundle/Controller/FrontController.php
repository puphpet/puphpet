<?php

namespace Puphpet\Extension\VarnishBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionVarnishBundle:form:Varnish.html.twig', [
            'varnish' => $data,
        ]);
    }
}
