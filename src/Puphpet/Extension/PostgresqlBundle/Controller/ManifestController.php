<?php

namespace Puphpet\Extension\PostgresqlBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionPostgresqlBundle:manifest:Postgresql.pp.twig', [
            'data' => $data,
        ]);
    }
}
