<?php

namespace Puphpet\Extension\VagrantfileBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class VagrantfileController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionVagrantfileBundle:form:Vagrantfile.html.twig', [
            'vagrantfile' => $data,
        ]);
    }

    public function syncedFolderAction()
    {
        return $this->render('PuphpetExtensionVagrantfileBundle:form/sections:SyncedFolder.html.twig', [
            'synced_folder' => $this->getData()['empty_synced_folder'],
        ]);
    }

    public function forwardedPortAction()
    {
        return $this->render('PuphpetExtensionVagrantfileBundle:form/sections:ForwardedPort.html.twig', [
            'forwarded_port' => array_shift($this->getData()['vm']['network']['forwarded_port']),
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.vagrantfile.configure');
        return $config->getData();
    }
}
