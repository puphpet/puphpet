<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class CronController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/cron",
     *     name="puphpet.cron.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::cron.html.twig', [
            'cron' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/cron/job",
     *     name="puphpet.cron.job")
     * @Method({"GET"})
     */
    public function jobAction(Request $request)
    {
        $data = $this->getExtensionData('cron');

        return $this->render('PuphpetBundle:cron:job.html.twig', [
            'job' => $data['empty_job'],
        ]);
    }
}
