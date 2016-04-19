<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class ElasticSearchController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:elastic-search:form.html.twig', [
            'elastic_search' => $data,
        ]);
    }

    public function instanceAction()
    {
        return $this->render('PuphpetBundle:elastic-search/sections:instance.html.twig', [
            'instance' => $this->getData()['empty_instance'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionAvailableData('elastic-search');
    }
}
