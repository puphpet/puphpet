<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;
use PuphpetBundle\Helper;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;
use Symfony\Component\HttpFoundation\JsonResponse;
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
            'vhostId'   => $vhostId,
            'directory' => $data['empty_files_match'],
        ]);
    }

    /**
     * @param Request $request
     * @param string  $vhostId
     * @param string  $pregenerated
     * @return Response
     * @Route("/extension/apache/pregenerated-directory/{vhostId}/{pregenerated}",
     *     name="puphpet.apache.pregenerated_directory")
     * @Method({"GET"})
     */
    public function pregeneratedDirectoryAction(Request $request, string $vhostId, string $pregenerated = null)
    {
        $data = $this->getExtensionData('apache');

        $pregenerated = empty($pregenerated) ? 'html' : $pregenerated;
        $directories  = empty($data['pregenerated_directories'][$pregenerated])
            ? $data['pregenerated_directories']['html']
            : $data['pregenerated_directories'][$pregenerated];

        $randString = Helper\Strings::randString(3);
        $rendered   = [];

        foreach ($directories as $uniqid => $directory) {
            $template = "PuphpetBundle:apache:{$directory['provider']}.html.twig";

            $rendered []= $this->renderView($template, [
                'uniqid'    => "{$uniqid}_{$randString}",
                'vhostId'   => $vhostId,
                'directory' => $directory,
            ]);
        }

        $response = new JsonResponse();
        $response->setContent(json_encode($rendered));

        return $response;
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
