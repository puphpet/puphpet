<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class NodeJsController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:nodejs:form.html.twig', [
            'nodejs' => $data,
        ]);
    }
}
