<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class PhpController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/php",
     *     name="puphpet.php.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::php.html.twig', [
            'php' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/php/add-fpm-pool",
     *     name="puphpet.php.add_fpm_pool")
     * @Method({"GET"})
     */
    public function addFpmPoolAction(Request $request)
    {
        $data = $this->getExtensionData('php');

        return $this->render('PuphpetBundle:php:fpm-pool.html.twig', [
            'pool'                   => $data['empty_fpm_pool'],
            'available_fpm_pool_ini' => $data['fpm_pool_ini'],
        ]);
    }
}
