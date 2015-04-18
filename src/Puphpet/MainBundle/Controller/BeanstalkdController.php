<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class BeanstalkdController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:Beanstalkd:form.html.twig', [
            'beanstalkd' => $data,
        ]);
    }
}
