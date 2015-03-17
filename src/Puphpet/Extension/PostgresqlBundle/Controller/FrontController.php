<?php

namespace Puphpet\Extension\PostgresqlBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionPostgresqlBundle::form.html.twig', [
            'postgresql' => $data,
        ]);
    }

    public function addUserAction()
    {
        return $this->render('PuphpetExtensionPostgresqlBundle:sections:User.html.twig', [
            'user' => $this->getData()['empty_user'],
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetExtensionPostgresqlBundle:sections:Database.html.twig', [
            'database' => $this->getData()['empty_database'],
        ]);
    }

    public function addGrantAction()
    {
        return $this->render('PuphpetExtensionPostgresqlBundle:sections:Grant.html.twig', [
            'grant'                => $this->getData()['empty_grant'],
            'available_privileges' => $this->getData()['available_privileges'],
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
