<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class WpCliController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:wpcli:form.html.twig', [
            'wpcli' => $data,
        ]);
    }
}
