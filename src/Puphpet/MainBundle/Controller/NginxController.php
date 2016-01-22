<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class NginxController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:nginx:form.html.twig', [
            'nginx' => $data,
        ]);
    }

    public function vhostAction()
    {
        return $this->render('PuphpetMainBundle:nginx/sections:vhost.html.twig', [
            'vhost' => $this->getData()['empty_vhost'],
        ]);
    }

    public function vhostRewriteAction(Request $request)
    {
        return $this->render('PuphpetMainBundle:nginx/sections:vhost_rewrite.html.twig', [
            'vhostId' => $request->get('vhostId'),
            'rewrite' => $this->getData()['empty_vhost_rewrite'],
        ]);
    }

    public function locationAction(Request $request)
    {
        return $this->render('PuphpetMainBundle:nginx/sections:location.html.twig', [
            'vhostId'  => $request->get('vhostId'),
            'location' => $this->getData()['empty_location'],
        ]);
    }

    public function locationRewriteAction(Request $request)
    {
        return $this->render('PuphpetMainBundle:nginx/sections:location_rewrite.html.twig', [
            'vhostId'    => $request->get('vhostId'),
            'locationId' => $request->get('locationId'),
            'rewrite'    => $this->getData()['empty_location_rewrite'],
        ]);
    }

    public function upstreamAction()
    {
        return $this->render('PuphpetMainBundle:nginx/sections:upstream.html.twig', [
            'upstream' => $this->getData()['empty_upstream'],
        ]);
    }

    public function proxyAction()
    {
        return $this->render('PuphpetMainBundle:nginx/sections:proxy.html.twig', [
            'proxy' => $this->getData()['empty_proxy'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('nginx');
    }
}
