<?php

namespace Puphpet\Extension\VagrantfileRackspaceBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionVagrantfileRackspaceBundle::Vagrantfile.rb.twig', [
            'data' => $data,
        ]);
    }
}
