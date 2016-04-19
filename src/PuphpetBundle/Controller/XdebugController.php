<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class XdebugController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:xdebug:form.html.twig', [
            'xdebug' => $data,
        ]);
    }
}
