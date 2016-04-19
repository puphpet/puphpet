<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FirewallController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:firewall:form.html.twig', [
            'firewall' => $data,
        ]);
    }

    public function ruleAction()
    {
        return $this->render('PuphpetBundle:firewall/sections:rule.html.twig', [
            'rule' => $this->getData()['empty_rule'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('firewall');
    }
}
