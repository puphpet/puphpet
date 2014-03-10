<?php

namespace Puphpet\Extension\RabbitMQBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionRabbitMQBundle:manifest:RabbitMQ.pp.twig', [
            'data' => $data,
        ]);
    }
}
