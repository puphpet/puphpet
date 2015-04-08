<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class UserGroupController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:user-group:form.html.twig', [
            'ug' => $data,
        ]);
    }
}
