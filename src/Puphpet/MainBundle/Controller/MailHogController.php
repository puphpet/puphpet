<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class MailHogController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:MailHog:form.html.twig', [
            'mailhog' => $data,
        ]);
    }
}
