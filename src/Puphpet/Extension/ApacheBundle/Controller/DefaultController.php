<?php

namespace Puphpet\Extension\ApacheBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\Yaml\Yaml;

class DefaultController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data = [])
    {
        if (empty($data)) {
            $data = $this->getData();
        }

        return $this->render('PuphpetExtensionApacheBundle:form:Apache.html.twig', [
            'apache' => $data,
        ]);
    }

    public function vhostAction()
    {
        return $this->render('PuphpetExtensionApacheBundle:form/sections:vhost.html.twig', [
            'vhost' => array_shift($this->getData()['vhosts']),
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        return Yaml::parse(__DIR__ . '/../Resources/config/data.yml');
    }
}
