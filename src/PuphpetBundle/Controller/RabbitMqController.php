<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class RabbitMqController extends Controller
{
    /**
     * @param Request $request
     * @param array   $data
     * @return Response
     * @Route("/extension/rabbitmq",
     *     name="puphpet.rabbitmq.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request, array $data)
    {
        return $this->render('PuphpetBundle::rabbitmq.html.twig', [
            'rabbitmq' => $data,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/extension/rabbitmq/user",
     *     name="puphpet.rabbitmq.user")
     * @Method({"GET"})
     */
    public function userAction(Request $request)
    {
        $data = $this->getExtensionData('rabbitmq');

        return $this->render('PuphpetBundle:rabbitmq:user.html.twig', [
            'user' => $data['empty_user'],
        ]);
    }

    /**
     * @param Request $request
     * @param string  $userId
     * @return Response
     * @Route("/extension/rabbitmq/permission/{userId}",
     *     name="puphpet.rabbitmq.permission")
     * @Method({"GET"})
     */
    public function permissionAction(Request $request, string $userId)
    {
        $data = $this->getExtensionData('rabbitmq');

        return $this->render('PuphpetBundle:rabbitmq:permission.html.twig', [
            'userId'     => $userId,
            'permission' => $data['empty_permission'],
        ]);
    }
}
