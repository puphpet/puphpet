<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class PackageController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:package:form.html.twig', [
            'server' => $data,
        ]);
    }
}
