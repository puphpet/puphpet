<?php

namespace Puphpet\Extension\NginxBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetMainBundle:extensions/nginx:form.html.twig', [
            'nginx' => $data,
        ]);
    }

    public function vhostAction()
    {
        return $this->render('PuphpetMainBundle:extensions/nginx/sections:vhost.html.twig', [
            'vhost'             => $this->getData()['empty_vhost'],
        ]);
    }

    public function locationAction(Request $request)
    {
        return $this->render('PuphpetMainBundle:extensions/nginx/sections:location.html.twig', [
            'vhostId'  => $request->get('vhostId'),
            'location' => $this->getData()['empty_location'],
        ]);
    }

    public function upstreamAction()
    {
        return $this->render('PuphpetMainBundle:extensions/nginx/sections:upstream.html.twig', [
            'upstream'          => $this->getData()['empty_upstream'],
        ]);
    }

    public function proxyAction()
    {
        return $this->render('PuphpetMainBundle:extensions/nginx/sections:proxy.html.twig', [
            'proxy' => $this->getData()['empty_proxy'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.nginx.configure');
        return $config->getData();
    }
}
