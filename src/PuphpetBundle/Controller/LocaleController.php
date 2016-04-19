<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class LocaleController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:locale:form.html.twig', [
            'locale' => $data,
        ]);
    }
}
