<?php

namespace Puphpet\Extension\FirewallBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionFirewallBundle:form:Firewall.html.twig', [
            'firewall' => $data,
            'extra'    => $extra,
        ]);
    }

    public function ruleAction()
    {
        $config = $this->get('puphpet.extension.firewall.configure');
        $data   = $config->getData();

        return $this->render('PuphpetExtensionFirewallBundle:form/sections:Rule.html.twig', [
            'rule' => $data['empty_rule'],
        ]);
    }
}
