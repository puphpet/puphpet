<?php

namespace Puphpet\Extension\ApacheBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetMainBundle:extensions/apache:form.html.twig', [
            'apache' => $data,
        ]);
    }

    public function vhostAction()
    {
        return $this->render('PuphpetMainBundle:extensions/apache/sections:vhost.html.twig', [
            'vhost' => $this->getData()['empty_vhost'],
        ]);
    }

    public function directoryAction(Request $request)
    {
        return $this->render('PuphpetMainBundle:extensions/apache/sections:directory.html.twig', [
            'vhostId'   => $request->get('vhostId'),
            'directory' => $this->getData()['empty_directory'],
        ]);
    }

    public function filesMatchAction(Request $request)
    {
        return $this->render('PuphpetMainBundle:extensions/apache/sections:filesMatch.html.twig', [
            'vhostId'     => $request->get('vhostId'),
            'directoryId' => $request->get('directoryId'),
            'filesMatch'  => $this->getData()['empty_files_match'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.apache.configure');
        return $config->getData();
    }
}
