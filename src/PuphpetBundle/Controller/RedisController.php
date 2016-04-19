<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class RedisController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:redis:form.html.twig', [
            'redis' => $data,
        ]);
    }
}
