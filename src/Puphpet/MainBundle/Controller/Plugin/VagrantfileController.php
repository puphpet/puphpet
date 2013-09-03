<?php

namespace Puphpet\MainBundle\Controller\Plugin;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\Yaml\Yaml;

class VagrantfileController extends Controller
{
    public function syncedFolderAction()
    {
        return $this->render('PuphpetMainBundle:Default/Plugins/Vagrantfile:SyncedFolder.html.twig', [
            'synced_folder' => array_shift($this->getData()['vm']['synced_folder']),
        ]);
    }

    public function forwardedPortAction()
    {
        return $this->render('PuphpetMainBundle:Default/Plugins/Vagrantfile:ForwardedPort.html.twig', [
            'forwarded_port' => array_shift($this->getData()['vm']['network']['forwarded_port']),
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $pluginDir = $this->container->getParameter('PLUGIN_DIR');
        return Yaml::parse("{$pluginDir}/Vagrantfile/config/data.yml");
    }
}
