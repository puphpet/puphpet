<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class RedisController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:redis:form.html.twig', [
            'redis' => $data,
        ]);
    }
}
