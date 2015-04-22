<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class PythonController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:Python::form.html.twig', [
            'python' => $data,
        ]);
    }

    public function addVersionAction()
    {
        return $this->render('PuphpetMainBundle:Python/sections:version.html.twig', [
            'selected_version'   => $this->getData()['empty_version'],
            'available_versions' => $this->getData()['versions'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('python');
    }
}
