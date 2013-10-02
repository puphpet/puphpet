<?php

namespace Puphpet\Extension\NginxBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionNginxBundle:manifest:Nginx.pp.twig', [
            'data' => $data,
        ]);
    }
}
