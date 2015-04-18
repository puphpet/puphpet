<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class XhprofController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:xhprof:form.html.twig', [
            'xhprof' => $data,
        ]);
    }
}
