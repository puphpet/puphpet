<?php

namespace Puphpet\MainBundle\Extension;

interface ExtensionInterface
{
    public function getName();

    public function getController();

    public function render(array $data = []);
}
