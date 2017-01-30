<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class ElasticSearchController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/elastic-search",
     *     name="puphpet.elastic_search.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::elastic-search.html.twig', [
            'elastic_search' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/elastic-search/instance",
     *     name="puphpet.elastic_search.instance")
     * @Method({"GET"})
     */
    public function instanceAction(Request $request)
    {
        $data = $this->getExtensionData('elastic-search');

        return $this->render('PuphpetBundle:elastic-search:instance.html.twig', [
            'instance' => $data['empty_instance'],
        ]);
    }
}
