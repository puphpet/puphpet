<?php

namespace Puphpet\Extension\RabbitMQBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionRabbitMQBundle:form:RabbitMQ.html.twig', [
            'rabbitmq' => $data,
        ]);
    }
}
