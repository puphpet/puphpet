<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class VagrantfileGceController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:vagrantfile-gce:form.html.twig', [
            'data' => $data,
        ]);
    }

    public function machineAction()
    {
        return $this->render('PuphpetBundle:vagrantfile-gce/sections:machine.html.twig', [
            'machine'       => $this->getData()['empty_machine'],
            'zones'         => $this->getData()['zones'],
            'machine_types' => $this->getData()['machine_types'],
        ]);
    }

    public function syncedFolderAction()
    {
        return $this->render('PuphpetBundle:vagrantfile-gce/sections:synced-folder.html.twig', [
            'synced_folder' => $this->getData()['empty_synced_folder'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('vagrantfile-gce');
    }
}
