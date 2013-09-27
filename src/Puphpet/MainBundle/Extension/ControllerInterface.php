<?php

namespace Puphpet\MainBundle\Extension;

use Symfony\Component\HttpFoundation\Response;

interface ControllerInterface
{
    /**
     * @param array $data
     * @return Response;
     */
    public function indexAction(array $data);
}
