<?php

namespace Puphpet\Extension\CronBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class FrontController extends Controller implements Extension\ControllerInterface
{
    public function indexAction(array $data, $extra = '')
    {
        return $this->render('PuphpetExtensionCronBundle::form.html.twig', [
            'cron'  => $data,
            'extra' => $extra,
        ]);
    }

    public function jobAction()
    {
        return $this->render('PuphpetExtensionCronBundle:sections:job.html.twig', [
            'job' => $this->getData()['empty_job'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $config = $this->get('puphpet.extension.cron.configure');
        return $config->getData();
    }
}
