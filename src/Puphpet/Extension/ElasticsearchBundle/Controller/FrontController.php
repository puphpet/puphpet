<?php

namespace Puphpet\Extension\ElasticsearchBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data)
    {
        
        return $this->render('PuphpetExtensionElasticsearchBundle:form:Elasticsearch.html.twig', [
            'elasticsearch' => $data,
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.elasticsearch.configure');
        return $config->getData();
    }
}
