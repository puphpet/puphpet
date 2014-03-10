<?php

namespace Puphpet\Extension\BeanstalkdBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionBeanstalkdBundle:form:Beanstalkd.html.twig', [
            'beanstalkd' => $data,
        ]);
    }
}
