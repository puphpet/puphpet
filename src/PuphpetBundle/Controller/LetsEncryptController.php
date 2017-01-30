<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class LetsEncryptController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/letsencrypt",
     *     name="puphpet.letsencrypt.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::letsencrypt.html.twig', [
            'letsencrypt' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/letsencrypt/add-domain",
     *     name="puphpet.letsencrypt.add_domain")
     * @Method({"GET"})
     */
    public function addDomainAction(Request $request)
    {
        $data = $this->getExtensionData('letsencrypt');

        return $this->render('PuphpetBundle:letsencrypt:domain.html.twig', [
            'domain' => $data['empty_domain'],
        ]);
    }
}
