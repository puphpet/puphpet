<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class ApacheController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:apache:form.html.twig', [
            'apache' => $data,
        ]);
    }

    public function vhostAction()
    {
        return $this->render('PuphpetMainBundle:apache/sections:vhost.html.twig', [
            'vhost' => $this->getData()['empty_vhost'],
        ]);
    }

    public function directoryAction(Request $request)
    {
        return $this->render('PuphpetMainBundle:apache/sections:directory.html.twig', [
            'vhostId'   => $request->get('vhostId'),
            'directory' => $this->getData()['empty_directory'],
        ]);
    }

    public function filesMatchAction(Request $request)
    {
        return $this->render('PuphpetMainBundle:apache/sections:filesMatch.html.twig', [
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
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionData('apache');
    }
}
