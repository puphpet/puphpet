<?php

namespace Puphpet\Extension\VagrantfileLocalBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionVagrantfileLocalBundle:manifest:vagrantfilelocal.pp.twig', [
            'data' => $data,
        ]);
    }
}
