<?php

namespace Puphpet\Extension\RubyBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionRubyBundle::form.html.twig', [
            'ruby'   => $data,
            'extra' => $extra,
        ]);
    }

    public function addVersionAction()
    {
        return $this->render('PuphpetExtensionRubyBundle:sections:Version.html.twig', [
            'selected_version'   => $this->getData()['empty_version'],
            'available_versions' => $this->getData()['available_versions'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.ruby.configure');
        return $config->getData();
    }
}
