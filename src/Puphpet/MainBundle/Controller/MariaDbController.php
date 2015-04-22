<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class MariaDbController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:mariadb:form.html.twig', [
            'mariadb'              => $data,
            'available_privileges' => $this->getData()['privileges'],
        ]);
    }

    public function addUserAction()
    {
        return $this->render('PuphpetMainBundle:mariadb/sections:user.html.twig', [
            'user' => $this->getData()['empty_user'],
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetMainBundle:mariadb/sections:database.html.twig', [
            'database' => $this->getData()['empty_database'],
        ]);
    }

    public function addGrantAction()
    {
        return $this->render('PuphpetMainBundle:mariadb/sections:grant.html.twig', [
            'grant'                => $this->getData()['empty_grant'],
            'available_privileges' => $this->getData()['privileges'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('mariadb');
    }
}
