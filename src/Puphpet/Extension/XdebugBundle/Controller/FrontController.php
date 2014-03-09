<?php

namespace Puphpet\Extension\XdebugBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionXdebugBundle:form:Xdebug.html.twig', [
            'xdebug' => $data,
        ]);
    }
}
