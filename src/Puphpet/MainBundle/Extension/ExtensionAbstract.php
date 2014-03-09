<?php

namespace Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;
use Symfony\Component\Yaml\Yaml;

abstract class ExtensionAbstract implements ExtensionInterface
{
    protected $container;
    protected $customData = [];
    protected $data = [];
    protected $dataLocation;
    protected $name;
    protected $returnAvailableData = true;
    protected $slug;
    protected $sources = [];
    protected $targetFile;

    /**
     * @param Container $container
     */
    public function __construct(Container $container)
    {
        $this->container = $container;
    }

    /**
     * Get extension's English name, eg "Apache"
     *
     * @return string
     * @throws \Exception
     */
    public function getName()
    {
        if (!$this->name) {
            throw new \Exception('Extension name has not been defined');
        }

        return $this->name;
    }

    /**
     * Get url-friendly slug, eg "vagrantfile-local"
     *
     * @return string
     * @throws \Exception
     */
    public function getSlug()
    {
        if (!$this->slug) {
            throw new \Exception('Extension slug has not been defined');
        }

        return $this->slug;
    }

    /**
     * Run extension's front controller action and return rendered content
     *
     * @param array  $data  Data required by controller template
     * @param string $extra Extra template string not belonging to specific extension
     * @return string
     */
    public function renderFront(array $data = [], $extra = null)
    {
        return $this->getFrontController()
            ->indexAction($data, $extra)
            ->getContent();
    }

    /**
     * Run extension's manifest controller action and return rendered content
     *
     * @param array $data Data required by controller template
     * @return string
     */
    public function renderManifest(array $data = [])
    {
        return $this->getManifestController()
            ->indexAction($data)
            ->getContent();
    }

    /**
     * Flag for returning available options in data
     *
     * eg all available PHP modules that user can choose from in drop down
     *
     * This is not desirable to show in the final hiera file
     *
     * @param bool $value
     * @return $this
     */
    public function setReturnAvailableData($value)
    {
        $this->returnAvailableData = $value;

        return $this;
    }

    /**
     * Whether any data came from outside sources
     *
     * eg user submitted their pre-generated hiera file
     *
     * @return bool
     */
    public function hasCustomData()
    {
        return empty($this->customData) ? false : true;
    }

    /**
     * Return the file the extension output will be saved to
     *
     * @return string
     */
    public function getTargetFile()
    {
        return $this->targetFile;
    }

    /**
     * If extension requires downloaded, returns associative array for puppet librarian
     *
     * name => url (url is optional)
     *
     * @return array
     */
    public function getSources()
    {
        if (empty($this->sources)) {
            return [];
        }

        return $this->sources;
    }

    /**
     * Return all data needed for our templates
     *
     * @return array
     */
    public function getData()
    {
        // User-specified, or the default filled-on data
        $dataToMerge = empty($this->customData)
            ? $this->yamlParse('defaults.yml')
            : $this->customData;

        // All available options. Don't want these in generated user-facing yaml file
        if ($this->returnAvailableData) {
            $dataToMerge = array_merge(
                $this->getAvailableData(),
                $dataToMerge
            );
        }

        // Sane defaults for all data options
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
     * @return $this
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
    protected function getDefaultData()
    {
        if (empty($this->data)) {
            $this->data = $this->yamlParse('data.yml');
        }

        return $this->data;
    }

    /**
     * Grab data to fill out available options
     *
     * @return array
     */
    protected function getAvailableData()
    {
        $available = $this->yamlParse('available.yml');

        return is_array($available)
            ? $available
            : [];
    }

    /**
     * Parse a YAML file from dataLocation root
     *
     * @param string $file
     * @return array
     */
    protected function yamlParse($file)
    {
        return Yaml::parse($this->dataLocation . '/' . $file);
    }
}
