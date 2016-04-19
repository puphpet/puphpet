<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class PhpController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:php:form.html.twig', [
            'php' => $data,
        ]);
    }

    public function addFpmPoolAction()
    {
        return $this->render('PuphpetBundle:php/sections:fpm-pool.html.twig', [
            'pool'                   => $this->getData()['empty_fpm_pool'],
            'available_fpm_pool_ini' => $this->getData()['fpm_pool_ini'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('php');
    }
}
