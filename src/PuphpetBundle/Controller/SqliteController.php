<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class SqliteController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/sqlite",
     *     name="puphpet.sqlite.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::sqlite.html.twig', [
            'sqlite' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/sqlite/add-database",
     *     name="puphpet.sqlite.add_database")
     * @Method({"GET"})
     */
    public function addDatabaseAction(Request $request)
    {
        $data = $this->getExtensionData('sqlite');

        return $this->render('PuphpetBundle:sqlite:user-database.html.twig', [
            'database' => $data['empty_database'],
        ]);
    }
}
