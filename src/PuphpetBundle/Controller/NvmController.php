<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class NvmController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:nvm:form.html.twig', [
          'nvm' => $data,
        ]);
    }
}
