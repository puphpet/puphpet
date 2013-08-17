<?php

namespace Puphpet\Domain;

interface PluginInterface
{
    public function getName();
    public function getData();
    public function getTemplateOrder();
    public function sanitize();
    public function process();
}
