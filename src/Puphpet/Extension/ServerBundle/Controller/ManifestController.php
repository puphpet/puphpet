<?php

namespace Puphpet\Extension\ServerBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionServerBundle:manifest:Server.pp.twig', [
            'data' => $data,
        ]);
    }
}
