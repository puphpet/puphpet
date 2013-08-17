<?php

namespace Puphpet\Plugin\Vagrantfile;

use Puphpet\Domain;

class Register implements Domain\PluginInterface
{
    /** @var array */
    private $data = [];

    /**
     * Data for plugin's use
     *
     * @param array $data
     */
    public function __construct(array $data)
    {
        $this->data = $data;
    }

    /**
     * Get name of plugin
     *
     * @return string
     */
    public function getName()
    {
        return 'vagrantfile';
    }

    /**
     * Return data available to plugin
     *
     * @return array
     */
    public function getData()
    {
        return $this->data;
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

    /**
     * @return array
     */
    public function getTemplateOrder()
    {
        return [
            'Vagrantfile.pp'
        ];
    }

    public function process()
    {
        //
    }
}
