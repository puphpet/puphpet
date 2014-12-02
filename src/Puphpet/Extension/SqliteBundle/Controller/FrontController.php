<?php

namespace Puphpet\Extension\SqliteBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionSqliteBundle::form.html.twig', [
            'sqlite' => $data,
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetExtensionSqliteBundle:sections:OwnerAndDatabase.html.twig', [
            'database' => $this->getData()['empty_database'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.sqlite.configure');
        return $config->getData();
    }
}
