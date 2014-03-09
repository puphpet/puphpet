<?php

namespace Puphpet\Extension\DrushBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionDrushBundle:form:Drush.html.twig', [
            'drush' => $data,
        ]);
    }
}
