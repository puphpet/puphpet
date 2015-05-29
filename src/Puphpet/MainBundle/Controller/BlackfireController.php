<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class BlackfireController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle::blackfire::form.html.twig', [
            'blackfire' => $data,
        ]);
    }
}
