<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class LetsEncryptController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:letsencrypt:form.html.twig', [
            'letsencrypt' => $data,
        ]);
    }

    public function addDomainAction()
    {
        return $this->render('PuphpetBundle:letsencrypt/sections:domain.html.twig', [
            'domain' => $this->getData()['empty_domain'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('letsencrypt');
    }
}
