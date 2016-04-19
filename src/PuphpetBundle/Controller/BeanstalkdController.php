<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class BeanstalkdController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:Beanstalkd:form.html.twig', [
            'beanstalkd' => $data,
        ]);
    }
}
