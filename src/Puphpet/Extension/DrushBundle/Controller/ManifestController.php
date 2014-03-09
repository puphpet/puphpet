<?php

namespace Puphpet\Extension\DrushBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionDrushBundle:manifest:Drush.pp.twig', [
            'data' => $data,
        ]);
    }
}
