<?php

namespace Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

abstract class ExtensionAbstract
{
    protected $container;

    protected $name;
    protected $slug;

    /**
     * @param Container $container
     */
    public function __construct(Container $container)
    {
        $this->container = $container;
    }

    /**
     * @return string
     * @throws \Exception
     */
    public function getName()
    {
        if (!$this->name) {
            throw new \Exception('Extension name has not been defined');
        }

        return $this->name;
    }

    /**
     * @return string
     * @throws \Exception
     */
    public function getSlug()
    {
        if (!$this->slug) {
            throw new \Exception('Extension slug has not been defined');
        }

        return $this->slug;
    }

    /**
     * @return ControllerInterface
     */
    abstract public function getFrontController();

    /**
     * @return ControllerInterface
     */
    abstract public function getManifestController();

    /**
     * @param array $data
     * @return string
     */
    public function renderFront(array $data = [])
    {
        return $this->getFrontController()
            ->indexAction($data)
            ->getContent();
    }

    /**
     * @param array $data
     * @return string
     */
    public function renderManifest(array $data = [])
    {
        return $this->getManifestController()
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
