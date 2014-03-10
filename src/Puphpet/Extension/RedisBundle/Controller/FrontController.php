<?php

namespace Puphpet\Extension\RedisBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionRedisBundle:form:Redis.html.twig', [
            'redis' => $data,
        ]);
    }
}
