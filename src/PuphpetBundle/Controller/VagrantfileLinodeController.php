<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class VagrantfileLinodeController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:vagrantfile-linode:form.html.twig', [
            'data' => $data,
        ]);
    }

    public function machineAction()
    {
        return $this->render('PuphpetBundle:vagrantfile-linode/sections:machine.html.twig', [
            'machine'     => $this->getData()['empty_machine'],
            'datacenters' => $this->getData()['datacenters'],
            'plans'       => $this->getData()['plans'],
        ]);
    }

    public function syncedFolderAction()
    {
        return $this->render('PuphpetBundle:vagrantfile-linode/sections:synced-folder.html.twig', [
            'synced_folder' => $this->getData()['empty_synced_folder'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('vagrantfile-linode');
    }
}
