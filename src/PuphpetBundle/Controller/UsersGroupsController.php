<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class UsersGroupsController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/users-groups",
     *     name="puphpet.users_groups.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::users-groups.html.twig', [
            'ug' => $data,
        ]);
    }
}
