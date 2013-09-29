<?php

namespace Puphpet\MainBundle\Extension;

interface ExtensionInterface
{
    public function getName();

    public function getSlug();

    public function getFrontController();

    public function render(array $data = []);

    public function getData();

    public function setCustomData(array $data = []);

    public function hasCustomData();
}
