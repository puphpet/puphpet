<?php

namespace Puphpet\Extension\VagrantfileLinodeBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionVagrantfileLinodeBundle::Vagrantfile.rb.twig', [
            'data' => $data,
        ]);
    }
}
