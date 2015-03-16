<?php

namespace Puphpet\Extension\JenkinsBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionJenkinsBundle::form.html.twig', [
            'jenkins' => $data,
        ]);
    }
}
