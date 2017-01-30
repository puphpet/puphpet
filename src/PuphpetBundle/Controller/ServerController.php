<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class ServerController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/server",
     *     name="puphpet.server.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::server.html.twig', [
            'server' => $data,
        ]);
    }
}
