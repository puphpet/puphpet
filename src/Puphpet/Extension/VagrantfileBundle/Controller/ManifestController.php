<?php

namespace Puphpet\Extension\VagrantfileBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionVagrantfileBundle:manifest:Vagrantfile.pp.twig', [
            'data' => $data,
        ]);
    }
}
