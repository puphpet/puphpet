<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class WpCliController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:wpcli:form.html.twig', [
            'wpcli' => $data,
        ]);
    }
}
