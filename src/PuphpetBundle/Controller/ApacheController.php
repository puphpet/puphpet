<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class ApacheController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/apache",
     *     name="puphpet.apache.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::apache.html.twig', [
            'apache' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/apache/vhost",
     *     name="puphpet.apache.vhost")
     * @Method({"GET"})
     */
    public function vhostAction(Request $request)
    {
        $data = $this->getExtensionData('apache');

        return $this->render('PuphpetBundle:apache:vhost.html.twig', [
            'vhost' => $data['empty_vhost'],
        ]);
    }

    /**
     * @param Request $request
     * @param string  $vhostId
     * @return Response
     * @Route("/extension/apache/directory/{vhostId}",
     *     name="puphpet.apache.directory")
     * @Method({"GET"})
     */
    public function directoryAction(Request $request, string $vhostId)
    {
        $data = $this->getExtensionData('apache');

        return $this->render('PuphpetBundle:apache:directory.html.twig', [
            'vhostId'   => $vhostId,
            'directory' => $data['empty_directory'],
        ]);
    }

    /**
     * @param Request $request
     * @param string  $vhostId
     * @return Response
     * @Route("/extension/apache/files-match/{vhostId}",
     *     name="puphpet.apache.files_match")
     * @Method({"GET"})
     */
    public function filesMatchAction(
        Request $request,
        string $vhostId
    ) {
        $data = $this->getExtensionData('apache');

        return $this->render('PuphpetBundle:apache:filesmatch.html.twig', [
            'vhostId'    => $vhostId,
            'filesMatch' => $data['empty_files_match'],
        ]);
    }

    /**
     * @param Request $request
     * @param string  $vhostId
     * @param string  $directiveId
     * @return Response
     * @Route("/extension/apache/rewrite/{vhostId}/{directiveId}",
     *     name="puphpet.apache.rewrite")
     * @Method({"GET"})
     */
    public function rewriteAction(
        Request $request,
        string $vhostId,
        string $directiveId
    ) {
        $data = $this->getExtensionData('apache');

        return $this->render('PuphpetBundle:apache:rewrite.html.twig', [
            'vhostId'     => $vhostId,
            'directiveId' => $directiveId,
            'rewrite'     => $data['empty_rewrite'],
        ]);
    }
}
