<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class NodeJsController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:nodejs:form.html.twig', [
            'nodejs' => $data,
        ]);
    }
}
