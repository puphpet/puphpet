<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class RabbitMqController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:rabbitmq:form.html.twig', [
            'rabbitmq' => $data,
        ]);
    }

    public function userAction()
    {
        return $this->render('PuphpetBundle:rabbitmq/sections:user.html.twig', [
            'user' => $this->getData()['empty_user'],
        ]);
    }

    public function permissionAction(Request $request)
    {
        return $this->render('PuphpetBundle:rabbitmq/sections:permission.html.twig', [
            'userId'     => $request->get('userId'),
            'permission' => $this->getData()['empty_permission'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('rabbitmq');
    }
}
