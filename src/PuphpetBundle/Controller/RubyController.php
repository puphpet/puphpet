<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class RubyController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/ruby",
     *     name="puphpet.ruby.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle:ruby:form.html.twig', [
            'ruby' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/ruby/add-version",
     *     name="puphpet.ruby.add_version")
     * @Method({"GET"})
     */
    public function addVersionAction(Request $request)
    {
        $data = $this->getExtensionData('ruby');

        return $this->render('PuphpetBundle:ruby/sections:version.html.twig', [
            'selected_version'   => $data['empty_version'],
            'available_versions' => $data['versions'],
        ]);
    }
}
