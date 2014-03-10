<?php

namespace Puphpet\Extension\BeanstalkdBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class ManifestController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionBeanstalkdBundle:manifest:Beanstalkd.pp.twig', [
            'data' => $data,
        ]);
    }
}
