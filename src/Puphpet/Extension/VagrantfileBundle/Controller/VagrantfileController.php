<?php

namespace Puphpet\Extension\VagrantfileBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\Yaml\Yaml;

class VagrantfileController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data = [])
    {
        if (empty($data)) {
            $data = $this->getData();
        }

        return $this->render('PuphpetExtensionVagrantfileBundle:form:Vagrantfile.html.twig', [
            'vagrantfile' => $data,
        ]);
    }

    public function syncedFolderAction()
    {
        return $this->render('PuphpetExtensionVagrantfileBundle:form/sections:SyncedFolder.html.twig', [
            'synced_folder' => array_shift($this->getData()['vm']['synced_folder']),
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
        return Yaml::parse(__DIR__ . '/../Resources/config/data.yml');
    }
}
