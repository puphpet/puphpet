<?php

namespace Puphpet\Extension\RabbitMQBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionRabbitMQBundle::form.html.twig', [
            'rabbitmq' => $data,
        ]);
    }

    public function userAction()
    {
        return $this->render('PuphpetExtensionRabbitMQBundle:sections:user.html.twig', [
            'user' => $this->getData()['empty_user'],
        ]);
    }

    public function permissionAction(Request $request)
    {
        return $this->render('PuphpetExtensionRabbitMQBundle:sections:permission.html.twig', [
            'userId'     => $request->get('userId'),
            'permission' => $this->getData()['empty_permission'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.rabbitmq.configure');
        return $config->getData();
    }
}
