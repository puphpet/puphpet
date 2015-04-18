<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class XdebugController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:xdebug:form.html.twig', [
            'xdebug' => $data,
        ]);
    }
}
