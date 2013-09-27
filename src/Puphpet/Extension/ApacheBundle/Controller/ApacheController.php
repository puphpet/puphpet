<?php

namespace Puphpet\Extension\ApacheBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ApacheController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionApacheBundle:form:Apache.html.twig', [
            'apache' => $data,
        ]);
    }

    public function vhostAction()
    {
        return $this->render('PuphpetExtensionApacheBundle:form/sections:vhost.html.twig', [
            'vhost' => $this->getData()['empty_vhost'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.apache.configure');
        return $config->getData();
    }
}
