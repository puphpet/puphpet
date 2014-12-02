<?php

namespace Puphpet\Extension\PythonBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionPythonBundle::form.html.twig', [
            'python' => $data,
            'extra'  => $extra,
        ]);
    }

    public function addVersionAction()
    {
        return $this->render('PuphpetExtensionPythonBundle:sections:Version.html.twig', [
            'selected_version'   => $this->getData()['empty_version'],
            'available_versions' => $this->getData()['available_versions'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.python.configure');
        return $config->getData();
    }
}
