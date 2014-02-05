<?php

namespace Puphpet\Extension\VagrantfileGceBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionVagrantfileGceBundleBundle:manifest:VagrantfileGceBundle.rb.twig', [
            'data' => $data,
        ]);
    }
}
