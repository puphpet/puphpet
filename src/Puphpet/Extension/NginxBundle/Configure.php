<?php

namespace Puphpet\Extension\NginxBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\Yaml\Yaml;

class Configure extends Extension\ExtensionAbstract implements Extension\ExtensionInterface
{
    private $data = [];
    private $customData = [];

    protected $name = 'Nginx';
    protected $slug = 'nginx';

    protected $targetFile = 'puppet/manifests/default.pp';
    protected $sources = [
        'nginx' => ":git => 'git://github.com/jfryman/puppet-nginx.git'",
    ];

    public function getFrontController()
    {
        return $this->container->get('puphpet.extension.nginx.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.nginx.manifest_controller');
    }

    /**
     * Return all data needed for our templates
     *
     * @return array
     */
    public function getData()
    {
        $dataToMerge = empty($this->customData)
            ? Yaml::parse(__DIR__ . '/Resources/config/defaults.yml')
            : $this->customData;

        $this->data = array_replace_recursive(
            $this->getDefaultData(),
            $dataToMerge
        );

        return $this->data;
    }

    /**
     * Add user-supplied values
     *
     * @param array $data
     * @return self
     */
    public function setCustomData(array $data = [])
    {
        $this->customData = $data;

        return $this;
    }

    /**
     * Our base data
     *
     * @return array
     */
    private function getDefaultData()
    {
        if (empty($this->data)) {
            $this->data = Yaml::parse(__DIR__ . '/Resources/config/data.yml');
        }

        return $this->data;
    }
}
