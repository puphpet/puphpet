<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class MailCatcherController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:MailCatcher:form.html.twig', [
            'mailcatcher' => $data,
        ]);
    }
}
