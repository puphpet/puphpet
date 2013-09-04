<?php

namespace Puphpet\MainBundle\Extension;

use Symfony\Component\HttpFoundation\Response;

interface ControllerInterface
{
    /**
     * @return Response;
     */
    public function indexAction();
}
