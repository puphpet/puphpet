<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class VagrantfileAwsController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:vagrantfile-aws:form.html.twig', [
            'data' => $data,
        ]);
    }

    public function machineAction()
    {
        return $this->render('PuphpetMainBundle:vagrantfile-aws/sections:machine.html.twig', [
            'machine'        => $this->getData()['empty_machine'],
            'instance_types' => $this->getData()['instance_types'],
            'regions'        => $this->getData()['regions'],
        ]);
    }

    public function syncedFolderAction()
    {
        return $this->render('PuphpetMainBundle:vagrantfile-aws/sections:synced-folder.html.twig', [
            'synced_folder' => $this->getData()['empty_synced_folder'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('vagrantfile-aws');
    }
}
