<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class MySqlController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/mysql",
     *     name="puphpet.mysql.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        $extensionData = $this->getExtensionData('mysql');

        return $this->render('PuphpetBundle:mysql:form.html.twig', [
            'mysql'                => $data,
            'available_privileges' => $extensionData['privileges'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/mysql/add-user",
     *     name="puphpet.mysql.add_user")
     * @Method({"GET"})
     */
    public function addUserAction(Request $request)
    {
        $extensionData = $this->getExtensionData('mysql');

        return $this->render('PuphpetBundle:mysql/sections:user.html.twig', [
            'user' => $extensionData['empty_user'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/mysql/add-database",
     *     name="puphpet.mysql.add_database")
     * @Method({"GET"})
     */
    public function addDatabaseAction(Request $request)
    {
        $extensionData = $this->getExtensionData('mysql');

        return $this->render('PuphpetBundle:mysql/sections:database.html.twig', [
            'database' => $extensionData['empty_database'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/mysql/add-grant",
     *     name="puphpet.mysql.add_grant")
     * @Method({"GET"})
     */
    public function addGrantAction(Request $request)
    {
        $extensionData = $this->getExtensionData('mysql');

        return $this->render('PuphpetBundle:mysql/sections:grant.html.twig', [
            'grant'                => $extensionData['empty_grant'],
            'available_privileges' => $extensionData['privileges'],
        ]);
    }
}
