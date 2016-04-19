<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class DrushController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle::drush::form.html.twig', [
            'drush' => $data,
        ]);
    }
}
