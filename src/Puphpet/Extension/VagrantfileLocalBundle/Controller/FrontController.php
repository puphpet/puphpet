<?php

namespace Puphpet\Extension\VagrantfileLocalBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionVagrantfileLocalBundle:form:VagrantfileLocal.html.twig', [
            'data' => $data,
        ]);
    }

    public function syncedFolderAction()
    {

        $data = $this->getData();

        return $this->render('PuphpetExtensionVagrantfileLocalBundle:form/sections:SyncedFolder.html.twig', [
            'synced_folder' => $data['empty_synced_folder'],
            'data'=> $data,
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
        $config = $this->get('puphpet.extension.vagrantfile.local.configure');
        return $config->getData();
    }
}
