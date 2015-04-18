<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ServerController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:server:form.html.twig', [
            'server' => $data,
        ]);
    }
}
