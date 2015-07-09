<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class LocaleController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:locale:form.html.twig', [
            'locale' => $data,
        ]);
    }
}
