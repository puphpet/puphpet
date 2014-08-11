<?php

namespace Puphpet\Extension\PythonBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionPythonBundle:form:Python.html.twig', [
            'python' => $data,
            'extra'  => $extra,
        ]);
    }
}
