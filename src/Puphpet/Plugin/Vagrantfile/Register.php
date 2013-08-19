<?php

namespace Puphpet\Plugin\Vagrantfile;

use Puphpet\Domain;

class Register implements Domain\PluginInterface
{
    /** @var array */
    private $data = [];

    /** @var string */
    private $parsedTemplate;

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
     * Destination file
     *
     * @return string
     */
    public function getFileDestination()
    {
        return 'Vagrantfile';
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
     * @return array
     */
    public function getTemplateOrder()
    {
        return [
            'Vagrantfile.pp'
        ];
    }

    /**
     * Save the plugin's parsed template
     *
     * @param string $string Parsed template
     * @return self
     */
    public function setParsedTemplate($string)
    {
        $this->parsedTemplate = $string;

        return $this;
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
