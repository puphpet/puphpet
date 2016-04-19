<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class PostgreSqlController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:postgresql:form.html.twig', [
            'postgresql' => $data,
        ]);
    }

    public function addUserAction()
    {
        return $this->render('PuphpetBundle:postgresql/sections:user.html.twig', [
            'user' => $this->getData()['empty_user'],
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetBundle:postgresql/sections:database.html.twig', [
            'database' => $this->getData()['empty_database'],
        ]);
    }

    public function addGrantAction()
    {
        return $this->render('PuphpetBundle:postgresql/sections:grant.html.twig', [
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
        return $manager->getExtensionAvailableData('postgresql');
    }
}
