<?php

namespace Puphpet\Extension\PostgresqlBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionPostgresqlBundle:form:Postgresql.html.twig', [
            'postgresql' => $data,
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetExtensionPostgresqlBundle:form/sections:NewUserAndDatabase.html.twig', [
            'available_privileges' => $this->getData()['available_privileges'],
            'database'             => $this->getData()['empty_database'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.postgresql.configure');
        return $config->getData();
    }
}
