<?php

namespace Puphpet\Domain\Configuration;

/**
 * Configuration container for a box setup
 */
class Edition
{

    /**
     * @var \Symfony\Component\PropertyAccess\PropertyAccessor
     */
    private $accessor;

    /**
     * @var array
     */
    private $configuration;

    /**
     * Constructor
     *
     * @param PropertyAccessProvider $propertyAccessProvider
     */
    public function __construct(PropertyAccessProvider $propertyAccessProvider)
    {
        $this->accessor = $propertyAccessProvider->provide();
    }

    /**
     * @param array $configuration
     */
    public function setConfiguration(array $configuration)
    {
        $this->configuration = $configuration;
    }

    /**
     * Returns complete configuration
     *
     * @return array
     */
    public function getConfiguration()
    {
        return $this->configuration;
    }

    /**
     * Returns value of a given property
     *
     * @param string $property property in PropertyAccess format ('[foo]', not 'foo)
     *
     * @return mixed the property value
     */
    public function get($property)
    {
        return $this->accessor->getValue($this->configuration, $property);
    }

    /**
     * Sets the value for a property
     *
     * @param string $property property in PropertyAccess format
     * @param mixed  $value
     */
    public function set($property, $value)
    {
        $this->accessor->setValue($this->configuration, $property, $value);
    }
}
