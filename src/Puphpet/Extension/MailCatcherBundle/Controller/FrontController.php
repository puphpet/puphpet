<?php

namespace Puphpet\Extension\MailCatcherBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionMailCatcherBundle:form:MailCatcher.html.twig', [
            'mailcatcher' => $data,
        ]);
    }
}
