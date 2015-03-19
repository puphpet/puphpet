<?php

namespace Puphpet\Extension\MysqlBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionMysqlBundle::form.html.twig', [
            'mysql'                => $data,
            'available_privileges' => $this->getData()['available_privileges'],
        ]);
    }

    public function addUserAction()
    {
        return $this->render('PuphpetExtensionMysqlBundle:sections:User.html.twig', [
            'user' => $this->getData()['empty_user'],
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetExtensionMysqlBundle:sections:Database.html.twig', [
            'database' => $this->getData()['empty_database'],
        ]);
    }

    public function addGrantAction()
    {
        return $this->render('PuphpetExtensionMysqlBundle:sections:Grant.html.twig', [
            'grant'                => $this->getData()['empty_grant'],
            'available_privileges' => $this->getData()['available_privileges'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.mysql.configure');
        return $config->getData();
    }
}
