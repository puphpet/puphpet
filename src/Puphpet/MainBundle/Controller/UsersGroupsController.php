<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class UsersGroupsController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:users-groups:form.html.twig', [
            'ug' => $data,
        ]);
    }
}
