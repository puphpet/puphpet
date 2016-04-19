<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ServerController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:server:form.html.twig', [
            'server' => $data,
        ]);
    }
}
