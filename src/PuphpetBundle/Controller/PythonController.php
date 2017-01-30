<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class PythonController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/python",
     *     name="puphpet.python.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle:python::form.html.twig', [
            'python' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/python/add-version",
     *     name="puphpet.python.add_version")
     * @Method({"GET"})
     */
    public function addVersionAction(Request $request)
    {
        $data = $this->getExtensionData('python');

        return $this->render('PuphpetBundle:python/sections:version.html.twig', [
            'selected_version'   => $data['empty_version'],
            'available_versions' => $data['versions'],
        ]);
    }
}
