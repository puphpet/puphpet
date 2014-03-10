<?php

namespace Puphpet\MainBundle\Extension;

use Symfony\Component\HttpFoundation\Response;

interface ControllerInterface
{
    /**
     * @param array  $data
     * @param string $extra
     * @return Response;
     */
    public function indexAction(array $data, $extra = '');
}
