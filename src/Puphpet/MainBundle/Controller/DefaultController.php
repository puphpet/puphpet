<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class DefaultController extends Controller
{
    public function indexAction()
    {
        return $this->render('PuphpetMainBundle:Default:index.html.twig', [
            'extensions' => $this->get('puphpet.extension.manager')->getParsed(),
        ]);
    }
}
