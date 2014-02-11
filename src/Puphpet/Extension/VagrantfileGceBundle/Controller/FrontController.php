<?php

namespace Puphpet\Extension\VagrantfileGceBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionVagrantfileGceBundleBundle:form:VagrantfileGceBundle.html.twig', [
            'data' => $data,
        ]);
    }

    public function syncedFolderAction()
    {
        return $this->render('VagrantfileGceBundle:form/sections:SyncedFolder.html.twig', [
            'synced_folder' => $this->getData()['empty_synced_folder'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.vagrantfile.gce.configure');
        return $config->getData();
    }
}
