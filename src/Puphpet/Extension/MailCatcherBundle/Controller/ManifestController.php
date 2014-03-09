<?php

namespace Puphpet\Extension\MailCatcherBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionMailCatcherBundle:manifest:MailCatcher.pp.twig', [
            'data' => $data,
        ]);
    }
}
