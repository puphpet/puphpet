<?php

namespace Puphpet\Extension\XhprofBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionXhprofBundle:manifest:Xhprof.pp.twig', [
            'data' => $data,
        ]);
    }
}
