<?php

namespace Puphpet\Extension\FirewallBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionFirewallBundle:manifest:Firewall.pp.twig', [
            'data' => $data,
        ]);
    }
}
