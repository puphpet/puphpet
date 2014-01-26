<?php

namespace Puphpet\Extension\SolrBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetExtensionSolrBundle:form:Solr.html.twig', [
            'solr' => $data,
        ]);
    }
}
