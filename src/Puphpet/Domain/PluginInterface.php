<?php

namespace Puphpet\Domain;

interface PluginInterface
{
    public function getName();
    public function getFileDestination();
    public function getData();
    public function getTemplateOrder();
    public function setParsedTemplate($string);
    public function sanitize();
    public function process();
}
