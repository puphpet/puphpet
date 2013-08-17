<?php

namespace Puphpet\Domain;

interface RegisterInterface
{
    public function register();
    public function sanitize();
    public function process();
}
