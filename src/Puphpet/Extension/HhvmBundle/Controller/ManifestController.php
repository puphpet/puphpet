<?php

namespace Puphpet\Extension\HhvmBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionHhvmBundle:manifest:Hhvm.pp.twig', [
            'data' => $data,
        ]);
    }
}
