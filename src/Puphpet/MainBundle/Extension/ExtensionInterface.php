<?php

namespace Puphpet\MainBundle\Extension;

interface ExtensionInterface
{
    /**
     * @return string
     */
    public function getName();

    /**
     * @return string
     */
    public function getSlug();

    /**
     * @param array $data
     * @return string
     */
    public function renderFront(array $data = []);

    /**
     * @return ControllerInterface
     */
    public function getFrontController();

    /**
     * @return ControllerInterface
     */
    public function getManifestController();

    /**
     * @param array $data
     * @return string
     */
    public function renderManifest(array $data = []);

    /**
     * @param bool $value
     * @return $this
     */
    public function setReturnAvailableData($value);

    /**
     * @return bool
     */
    public function hasCustomData();

    /**
     * @return string
     */
    public function getTargetFile();

    /**
     * @return array
     */
    public function getSources();

    /**
     * @return array
     */
    public function getData();

    /**
     * @param array $data
     * @return $this
     */
    public function setCustomData(array $data = []);
}
