<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class VagrantfileSoftlayerController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:vagrantfile-softlayer:form.html.twig', [
            'data' => $data,
        ]);
    }

    public function machineAction()
    {
        return $this->render('PuphpetMainBundle:vagrantfile-softlayer/sections:machine.html.twig', [
            'machine'     => $this->getData()['empty_machine'],
            'datacenters' => $this->getData()['datacenters'],
            'cpus'        => $this->getData()['cpus'],
            'memories'    => $this->getData()['memory'],
        ]);
    }

    public function syncedFolderAction()
    {
        return $this->render('PuphpetMainBundle:vagrantfile-softlayer/sections:synced-folder.html.twig', [
            'synced_folder' => $this->getData()['empty_synced_folder'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('vagrantfile-softlayer');
    }
}
