<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class RubyController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:ruby:form.html.twig', [
            'ruby' => $data,
        ]);
    }

    public function addVersionAction()
    {
        return $this->render('PuphpetBundle:ruby/sections:version.html.twig', [
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
        return $manager->getExtensionAvailableData('ruby');
    }
}
