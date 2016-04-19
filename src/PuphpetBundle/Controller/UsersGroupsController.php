<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class UsersGroupsController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:users-groups:form.html.twig', [
            'ug' => $data,
        ]);
    }
}
