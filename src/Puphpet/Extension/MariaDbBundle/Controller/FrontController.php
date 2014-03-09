<?php

namespace Puphpet\Extension\MariaDbBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionMariaDbBundle:form:MariaDb.html.twig', [
            'mariadb' => $data,
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetExtensionMariaDbBundle:form/sections:NewUserAndDatabase.html.twig', [
            'available_privileges' => $this->getData()['available_privileges'],
            'database'             => $this->getData()['empty_database'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.mariadb.configure');
        return $config->getData();
    }
}
