<?php

namespace Puphpet\Extension\MongoDbBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionMongoDbBundle:manifest:MongoDb.pp.twig', [
            'data' => $data,
        ]);
    }
}
