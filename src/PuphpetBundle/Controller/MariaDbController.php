<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class MariaDbController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/mariadb",
     *     name="puphpet.mariadb.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        $extensionData = $this->getExtensionData('mariadb');

        return $this->render('PuphpetBundle::mariadb.html.twig', [
            'mariadb'              => $data,
            'available_privileges' => $extensionData['privileges'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/mariadb/add-user",
     *     name="puphpet.mariadb.add_user")
     * @Method({"GET"})
     */
    public function addUserAction(Request $request)
    {
        $extensionData = $this->getExtensionData('mariadb');

        return $this->render('PuphpetBundle:mariadb:user.html.twig', [
            'user' => $extensionData['empty_user'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/mariadb/add-database",
     *     name="puphpet.mariadb.add_database")
     * @Method({"GET"})
     */
    public function addDatabaseAction(Request $request)
    {
        $extensionData = $this->getExtensionData('mariadb');

        return $this->render('PuphpetBundle:mariadb:database.html.twig', [
            'database' => $extensionData['empty_database'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/mariadb/add-grant",
     *     name="puphpet.mariadb.add_grant")
     * @Method({"GET"})
     */
    public function addGrantAction(Request $request)
    {
        $extensionData = $this->getExtensionData('mariadb');

        return $this->render('PuphpetBundle:mariadb:grant.html.twig', [
            'grant'                => $extensionData['empty_grant'],
            'available_privileges' => $extensionData['privileges'],
        ]);
    }
}
