<?php

namespace Puphpet\Extension\PhpBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionPhpBundle:manifest:Php.pp.twig', [
            'data' => $data,
        ]);
    }
}
