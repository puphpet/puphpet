<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class FirewallController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/firewall",
     *     name="puphpet.firewall.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::firewall.html.twig', [
            'firewall' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/firewall/forwarded-port",
     *     name="puphpet.firewall.rule")
     * @Method({"GET"})
     */
    public function ruleAction(Request $request)
    {
        $data = $this->getExtensionData('firewall');

        return $this->render('PuphpetBundle:firewall:rule.html.twig', [
            'rule' => $data['empty_rule'],
        ]);
    }
}
