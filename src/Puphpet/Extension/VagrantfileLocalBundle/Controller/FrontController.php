<?php

namespace Puphpet\Extension\VagrantfileLocalBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionVagrantfileLocalBundle:form:vagrantfilelocal.html.twig', [
            'data' => $data,
        ]);
    }

    public function syncedFolderAction()
    {
        return $this->render('PuphpetExtensionVagrantfileLocalBundle:form/sections:SyncedFolder.html.twig', [
            'synced_folder' => $this->getData()['empty_synced_folder'],
        ]);
    }

    public function forwardedPortAction()
    {
        return $this->render('PuphpetExtensionVagrantfileLocalBundle:form/sections:ForwardedPort.html.twig', [
            'forwarded_port' => array_shift($this->getData()['vm']['network']['forwarded_port']),
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.vagrantfilelocal.configure');
        return $config->getData();
    }
}
