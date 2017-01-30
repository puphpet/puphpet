<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class VagrantfileGceController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/vagrantfile-gce",
     *     name="puphpet.vagrantfile_gce.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle:vagrantfile-gce:form.html.twig', [
            'data' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/vagrantfile-gce/machine",
     *     name="puphpet.vagrantfile_gce.machine")
     * @Method({"GET"})
     */
    public function machineAction(Request $request)
    {
        $data = $this->getExtensionData('vagrantfile-gce');

        return $this->render('PuphpetBundle:vagrantfile-gce/sections:machine.html.twig', [
            'machine'       => $data['empty_machine'],
            'zones'         => $data['zones'],
            'machine_types' => $data['machine_types'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/vagrantfile-gce/synced-folder",
     *     name="puphpet.vagrantfile_gce.synced_folder")
     * @Method({"GET"})
     */
    public function syncedFolderAction(Request $request)
    {
        $data = $this->getExtensionData('vagrantfile-gce');

        return $this->render('PuphpetBundle:vagrantfile-gce/sections:synced-folder.html.twig', [
            'synced_folder' => $data['empty_synced_folder'],
        ]);
    }
}
