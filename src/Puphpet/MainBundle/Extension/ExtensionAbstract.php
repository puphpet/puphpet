<?php

namespace Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

abstract class ExtensionAbstract
{
    protected $container;

    /**
     * @param Container $container
     */
    public function __construct(Container $container)
    {
        $this->container = $container;
    }

    /**
     * @return string
     */
    abstract public function getName();

    /**
     * @return ControllerInterface
     */
    abstract public function getMainController();

    /**
     * @param array $data
     * @return string
     */
    public function getMainRender(array $data = [])
    {
        return $this->getMainController()
            ->indexAction($data)
            ->getContent();
    }
}
