<?php

namespace Puphpet\Domain;

use Pimple;

abstract class RegisterAbstract
{
    /** @var Pimple */
    protected $bucket;

    /** @var array */
    protected $data = [];

    public function __construct(Pimple $bucket, array $data = [])
    {
        $this->bucket = $bucket;
        $this->data = $data;
    }
}
