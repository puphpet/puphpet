<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class DrushController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle::drush::form.html.twig', [
            'drush' => $data,
        ]);
    }
}
