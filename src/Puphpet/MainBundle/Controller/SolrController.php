<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class SolrController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:Solr:form.html.twig', [
            'solr' => $data,
        ]);
    }
}
