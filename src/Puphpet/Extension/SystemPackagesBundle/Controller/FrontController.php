<?php

namespace Puphpet\Extension\SystemPackagesBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionSystemPackagesBundle::form.html.twig', [
            'server' => $data,
            'extra'  => $extra,
        ]);
    }
}
