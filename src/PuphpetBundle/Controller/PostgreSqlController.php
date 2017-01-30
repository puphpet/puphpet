<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class PostgreSqlController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/postgresql",
     *     name="puphpet.postgresql.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle:postgresql:form.html.twig', [
            'postgresql' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/postgresql/add-user",
     *     name="puphpet.postgresql.add_user")
     * @Method({"GET"})
     */
    public function addUserAction(Request $request)
    {
        $data = $this->getExtensionData('postgresql');

        return $this->render('PuphpetBundle:postgresql/sections:user.html.twig', [
            'user' => $data['empty_user'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/postgresql/add-database",
     *     name="puphpet.postgresql.add_database")
     * @Method({"GET"})
     */
    public function addDatabaseAction(Request $request)
    {
        $data = $this->getExtensionData('postgresql');

        return $this->render('PuphpetBundle:postgresql/sections:database.html.twig', [
            'database' => $data['empty_database'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/postgresql/add-grant",
     *     name="puphpet.postgresql.add_grant")
     * @Method({"GET"})
     */
    public function addGrantAction(Request $request)
    {
        $data = $this->getExtensionData('postgresql');

        return $this->render('PuphpetBundle:postgresql/sections:grant.html.twig', [
            'grant'                => $data['empty_grant'],
            'available_privileges' => $data['privileges'],
        ]);
    }
}
