<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class VagrantfileLinodeController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/vagrantfile-linode",
     *     name="puphpet.vagrantfile_linode.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::vagrantfile-linode.html.twig', [
            'data' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/vagrantfile-linode/machine",
     *     name="puphpet.vagrantfile_linode.machine")
     * @Method({"GET"})
     */
    public function machineAction(Request $request)
    {
        $data = $this->getExtensionData('vagrantfile-linode');

        return $this->render('PuphpetBundle:vagrantfile-linode:machine.html.twig', [
            'machine'     => $data['empty_machine'],
            'datacenters' => $data['datacenters'],
            'plans'       => $data['plans'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/vagrantfile-linode/synced-folder",
     *     name="puphpet.vagrantfile_linode.synced_folder")
     * @Method({"GET"})
     */
    public function syncedFolderAction(Request $request)
    {
        $data = $this->getExtensionData('vagrantfile-linode');

        return $this->render('PuphpetBundle:vagrantfile-linode:synced-folder.html.twig', [
            'synced_folder' => $data['empty_synced_folder'],
        ]);
    }
}
