<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class VagrantfileRackspaceController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/vagrantfile-rackspace",
     *     name="puphpet.vagrantfile_rackspace.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle:vagrantfile-rackspace:form.html.twig', [
            'data' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/vagrantfile-rackspace/machine",
     *     name="puphpet.vagrantfile_rackspace.machine")
     * @Method({"GET"})
     */
    public function machineAction(Request $request)
    {
        $data = $this->getExtensionData('vagrantfile-rackspace');

        return $this->render('PuphpetBundle:vagrantfile-rackspace/sections:machine.html.twig', [
            'machine' => $data['empty_machine'],
            'regions' => $data['regions'],
            'sizes'   => $data['sizes'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/vagrantfile-rackspace/synced-folder",
     *     name="puphpet.vagrantfile_rackspace.synced_folder")
     * @Method({"GET"})
     */
    public function syncedFolderAction(Request $request)
    {
        $data = $this->getExtensionData('vagrantfile-rackspace');

        return $this->render('PuphpetBundle:vagrantfile-rackspace/sections:synced-folder.html.twig', [
            'synced_folder' => $data['empty_synced_folder'],
        ]);
    }
}
