<?php

namespace Puphpet\Extension\ElasticSearchBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        
        return $this->render('PuphpetExtensionElasticSearchBundle:form:ElasticSearch.html.twig', [
            'elastic_search' => $data,
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.elastic_search.configure');
        return $config->getData();
    }
}
