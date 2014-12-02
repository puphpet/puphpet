<?php

namespace Puphpet\Extension\VagrantfileLocalBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionVagrantfileLocalBundle::Vagrantfile.rb.twig', [
            'data' => $data,
        ]);
    }
}
