<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class VagrantfileDigitalOceanController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/vagrantfile-digitalocean",
     *     name="puphpet.vagrantfile_digitalocean.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::vagrantfile-digitalocean.html.twig', [
            'data' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/vagrantfile-digitalocean/machine",
     *     name="puphpet.vagrantfile_digitalocean.machine")
     * @Method({"GET"})
     */
    public function machineAction(Request $request)
    {
        $data = $this->getExtensionData('vagrantfile-digitalocean');

        return $this->render('PuphpetBundle:vagrantfile-digitalocean:machine.html.twig', [
            'machine' => $data['empty_machine'],
            'regions' => $data['regions'],
            'sizes'   => $data['sizes'],
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/vagrantfile-digitalocean/synced-folder",
     *     name="puphpet.vagrantfile_digitalocean.synced_folder")
     * @Method({"GET"})
     */
    public function syncedFolderAction(Request $request)
    {
        $data = $this->getExtensionData('vagrantfile-digitalocean');

        return $this->render('PuphpetBundle:vagrantfile-digitalocean:synced-folder.html.twig', [
            'synced_folder' => $data['empty_synced_folder'],
        ]);
    }
}
