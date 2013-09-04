<?php

namespace Puphpet\Extension\ServerBasicsBundle\Controller;

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

        return $this->render('PuphpetExtensionServerBasicsBundle:form:ServerBasics.html.twig', [
            'server' => $data,
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
