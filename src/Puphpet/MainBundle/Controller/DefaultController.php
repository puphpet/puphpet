<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\Yaml\Yaml;

class DefaultController extends Controller
{
    public function indexAction()
    {
        return $this->render('PuphpetMainBundle:Default:index.html.twig', [
            'vagrantfile' => Yaml::parse(__DIR__ . '/../Plugin/Vagrantfile/config/data.yml'),
            'server'      => Yaml::parse(__DIR__ . '/../Plugin/Server/config/data.yml'),
        ]);
    }
}
