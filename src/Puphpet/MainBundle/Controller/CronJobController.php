<?php

namespace Puphpet\MainBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class CronJobController extends Controller
{
    public function indexAction(array $data)
    {
        return $this->render('PuphpetMainBundle:cron-job:form.html.twig', [
            'cron' => $data,
        ]);
    }

    public function jobAction()
    {
        return $this->render('PuphpetMainBundle:cron-job/sections:job.html.twig', [
            'job' => $this->getData()['empty_job'],
        ]);
    }

    /**
     * @return array
     */
    private function getData()
    {
        $manager = $this->get('puphpet.extension.manager');
        return $manager->getExtensionData('cron-job');
    }
}
