<?php

namespace Puphpet\Domain;

interface PluginInterface
{
    public function getName();
    public function sanitize();
    public function process();
}
