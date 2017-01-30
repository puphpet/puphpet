<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class MongoDbController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/mongodb",
     *     name="puphpet.mongodb.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle:mongodb:form.html.twig', [
            'mongodb' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/mongodb/add-database",
     *     name="puphpet.mongodb.add_database")
     * @Method({"GET"})
     */
    public function addDatabaseAction(Request $request)
    {
        $data = $this->getExtensionData('mongodb');

        return $this->render('PuphpetBundle:mongodb/sections:user-database.html.twig', [
            'database' => $data['empty_database'],
        ]);
    }
}
