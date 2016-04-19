<?php

namespace PuphpetBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class SolrController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetBundle:Solr:form.html.twig', [
            'solr' => $data,
        ]);
    }
}
