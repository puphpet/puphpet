<?php

namespace Puphpet\Extension\MongoDbBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionMongoDbBundle::form.html.twig', [
            'mongodb' => $data,
        ]);
    }

    public function addDatabaseAction()
    {
        return $this->render('PuphpetExtensionMongoDbBundle:sections:NewUserAndDatabase.html.twig', [
            'database' => $this->getData()['empty_database'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.mongodb.configure');
        return $config->getData();
    }
}
