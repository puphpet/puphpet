<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class MySqlController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:mysql:form.html.twig', [
            'mysql'                => $data,
            'available_privileges' => $this->getData()['privileges'],
        ]);
    }

    public function addUserAction()
    {
        return $this->render('PuphpetBundle:mysql/sections:user.html.twig', [
            'user' => $this->getData()['empty_user'],
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetBundle:mysql/sections:database.html.twig', [
            'database' => $this->getData()['empty_database'],
        ]);
    }

    public function addGrantAction()
    {
        return $this->render('PuphpetBundle:mysql/sections:grant.html.twig', [
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
        return $manager->getExtensionAvailableData('mysql');
    }
}
