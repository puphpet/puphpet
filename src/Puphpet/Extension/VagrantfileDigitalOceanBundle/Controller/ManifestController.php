<?php

namespace Puphpet\Extension\VagrantfileDigitalOceanBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetMainBundle:extensions/vagrantfile-digitalocean:Vagrantfile.rb.twig', [
            'data' => $data,
        ]);
    }
}
