<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class HhvmController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:hhvm:form.html.twig', [
            'hhvm' => $data,
        ]);
    }
}
