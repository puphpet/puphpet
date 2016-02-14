<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class VagrantfileLocalController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:vagrantfile-local:form.html.twig', [
            'data' => $data,
        ]);
    }

    public function machineAction()
    {
        return $this->render('PuphpetMainBundle:vagrantfile-local/sections:machine.html.twig', [
            'machine' => $this->getData()['empty_machine'],
        ]);
    }

    public function machineForwardedPortAction(Request $request)
    {
        return $this->render('PuphpetMainBundle:vagrantfile-local/sections:machine-forwarded-port.html.twig', [
            'mId'            => $request->get('mId'),
            'forwarded_port' => $this->getData()['empty_forwarded_port'],
        ]);
    }

    public function syncedFolderAction()
    {
        return $this->render('PuphpetMainBundle:vagrantfile-local/sections:synced-folder.html.twig', [
            'synced_folder' => $this->getData()['empty_synced_folder'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('vagrantfile-local');
    }
}
