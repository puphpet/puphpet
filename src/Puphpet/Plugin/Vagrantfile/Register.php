<?php

namespace Puphpet\Plugin\Vagrantfile;

use Puphpet\Domain;

class Register implements Domain\PluginInterface
{
    /** @var array */
    private $data = [];

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    /**
     * @return string
     */
    public function getName()
    {
        return 'vagrantfile';
    }

    /**
     * Sanitize data
     *
     * @return self
     */
    public function sanitize()
    {
        array_change_key_case($this->data, CASE_LOWER);

        return $this;
    }

    public function process()
    {
        //
    }
}
