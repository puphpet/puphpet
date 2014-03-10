<?php

namespace Puphpet\Extension\MysqlBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionMysqlBundle:form:Mysql.html.twig', [
            'mysql' => $data,
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetExtensionMysqlBundle:form/sections:NewUserAndDatabase.html.twig', [
            'available_privileges' => $this->getData()['available_privileges'],
            'database'             => $this->getData()['empty_database'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.mysql.configure');
        return $config->getData();
    }
}
