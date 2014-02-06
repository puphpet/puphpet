<?php

namespace Puphpet\Extension\ApcBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionApcBundle:manifest:Apc.pp.twig', [
            'data' => $data,
        ]);
    }
}
