<?php

namespace Puphpet\Extension\UserGroupBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetMainBundle:extensions/user-group:form.html.twig', [
            'ug'    => $data,
            'extra' => $extra,
        ]);
    }
}
