<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class MongoDbController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:mongodb:form.html.twig', [
            'mongodb' => $data,
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetBundle:mongodb/sections:user-database.html.twig', [
            'database' => $this->getData()['empty_database'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('mongodb');
    }
}
