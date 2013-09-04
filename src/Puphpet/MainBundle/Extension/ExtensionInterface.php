<?php

namespace Puphpet\MainBundle\Extension;

interface ExtensionInterface
{
    public function getName();

    public function getMainController();

    public function getMainRender(array $data = []);
}
