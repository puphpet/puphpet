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
    abstract public function getController();

    /**
     * @param array $data
     * @return string
     */
    public function render(array $data = [])
    {
        return $this->getController()
            ->indexAction($data)
            ->getContent();
    }

    /**
     * Whether any data came from outside sources
     *
     * @return bool
     */
    public function hasCustomData()
    {
        return empty($this->customData) ? false : true;
    }
}
