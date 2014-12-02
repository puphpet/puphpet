<?php

namespace Puphpet\Extension\WPCliBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionWPCliBundle::form.html.twig', [
            'wpcli' => $data,
        ]);
    }
}
