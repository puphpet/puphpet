<?php

namespace Puphpet\Extension\MariaDbBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionMariaDbBundle:manifest:MariaDb.pp.twig', [
            'data' => $data,
        ]);
    }
}
