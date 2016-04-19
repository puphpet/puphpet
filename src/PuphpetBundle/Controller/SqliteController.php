<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class SqliteController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:sqlite:form.html.twig', [
            'sqlite' => $data,
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetBundle:sqlite/sections:user-database.html.twig', [
            'database' => $this->getData()['empty_database'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('sqlite');
    }
}
