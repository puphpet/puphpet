<?php

namespace Puphpet\Extension\ElasticSearchBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionElasticSearchBundle:manifest:ElasticSearch.pp.twig', [
            'data' => $data,
        ]);
    }
}
