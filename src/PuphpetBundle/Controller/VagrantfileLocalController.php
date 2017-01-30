<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class VagrantfileLocalController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/vagrantfile-local",
     *     name="puphpet.vagrantfile_local.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle:vagrantfile-local:form.html.twig', [
            'data' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/vagrantfile-local/machine",
     *     name="puphpet.vagrantfile_local.machine")
     * @Method({"GET"})
     */
    public function machineAction(Request $request)
    {
        $data = $this->getExtensionData('vagrantfile-local');

        return $this->render('PuphpetBundle:vagrantfile-local/sections:machine.html.twig', [
            'machine' => $data['empty_machine'],
        ]);
    }

    /**
     * @param Request $request
     * @param string  $mId
     * @return Response
     * @Route("/extension/vagrantfile-local/machine-forwarded-port/{mId}",
     *     name="puphpet.vagrantfile_local.machine_forwarded_port")
     * @Method({"GET"})
     */
    public function machineForwardedPortAction(Request $request, string $mId)
    {
        $data = $this->getExtensionData('vagrantfile-local');

        return $this->render('PuphpetBundle:vagrantfile-local/sections:machine-forwarded-port.html.twig', [
            'mId'            => $mId,
            'forwarded_port' => $data['empty_forwarded_port'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/vagrantfile-local/synced-folder",
     *     name="puphpet.vagrantfile_local.synced_folder")
     * @Method({"GET"})
     */
    public function syncedFolderAction(Request $request)
    {
        $data = $this->getExtensionData('vagrantfile-local');

        return $this->render('PuphpetBundle:vagrantfile-local/sections:synced-folder.html.twig', [
            'synced_folder' => $data['empty_synced_folder'],
        ]);
    }
}
