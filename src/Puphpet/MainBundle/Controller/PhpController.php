<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class PhpController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:php:form.html.twig', [
            'php' => $data,
        ]);
    }
}
