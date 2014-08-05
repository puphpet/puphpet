<?php

namespace Puphpet\Extension\SqliteBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionSqliteBundle:manifest:Sqlite.pp.twig', [
            'data' => $data,
        ]);
    }
}
