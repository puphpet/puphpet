<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class VagrantfileRackspaceController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:vagrantfile-rackspace:form.html.twig', [
            'data' => $data,
        ]);
    }

    public function machineAction()
    {
        return $this->render('PuphpetBundle:vagrantfile-rackspace/sections:machine.html.twig', [
            'machine' => $this->getData()['empty_machine'],
            'regions' => $this->getData()['regions'],
            'sizes'   => $this->getData()['sizes'],
        ]);
    }

    public function syncedFolderAction()
    {
        return $this->render('PuphpetBundle:vagrantfile-rackspace/sections:synced-folder.html.twig', [
            'synced_folder' => $this->getData()['empty_synced_folder'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('vagrantfile-rackspace');
    }
}
