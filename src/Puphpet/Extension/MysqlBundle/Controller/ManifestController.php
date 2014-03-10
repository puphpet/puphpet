<?php

namespace Puphpet\Extension\MysqlBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionMysqlBundle:manifest:Mysql.pp.twig', [
            'data' => $data,
        ]);
    }
}
