<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class XhprofController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:xhprof:form.html.twig', [
            'xhprof' => $data,
        ]);
    }
}
