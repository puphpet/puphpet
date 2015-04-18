<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class MySqlController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:mysql:form.html.twig', [
            'mysql'                => $data,
            'available_privileges' => $this->getData()['available_privileges'],
        ]);
    }

    public function addUserAction()
    {
        return $this->render('PuphpetMainBundle:mysql/sections:user.html.twig', [
            'user' => $this->getData()['empty_user'],
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetMainBundle:mysql/sections:database.html.twig', [
            'database' => $this->getData()['empty_database'],
        ]);
    }

    public function addGrantAction()
    {
        return $this->render('PuphpetMainBundle:mysql/sections:grant.html.twig', [
            'grant'                => $this->getData()['empty_grant'],
            'available_privileges' => $this->getData()['available_privileges'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('mysql');
    }
}
