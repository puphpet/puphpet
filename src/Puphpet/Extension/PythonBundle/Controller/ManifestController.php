<?php

namespace Puphpet\Extension\PythonBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionPythonBundle:manifest:Python.pp.twig', [
            'python' => $data,
        ]);
    }
}