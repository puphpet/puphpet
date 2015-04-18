<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class PostgreSqlController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:postgresql:form.html.twig', [
            'postgresql' => $data,
        ]);
    }

    public function addUserAction()
    {
        return $this->render('PuphpetMainBundle:postgresql/sections:user.html.twig', [
            'user' => $this->getData()['empty_user'],
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetMainBundle:postgresql/sections:database.html.twig', [
            'database' => $this->getData()['empty_database'],
        ]);
    }

    public function addGrantAction()
    {
        return $this->render('PuphpetMainBundle:postgresql/sections:grant.html.twig', [
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
        return $manager->getExtensionAvailableData('postgresql');
    }
}
