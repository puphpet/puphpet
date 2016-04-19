<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class BlackfireController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle::blackfire::form.html.twig', [
            'blackfire' => $data,
        ]);
    }
}
