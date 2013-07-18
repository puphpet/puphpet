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
     * @var string
     */
    private $name;

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
     * @param string $name
     */
    public function setName($name)
    {
        $this->name = $name;
    }

    /**
     * @return string
     */
    public function getName()
    {
        return $this->name;
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
     * @param string $property property in PropertyAccess format e.g '[foo][bar]'
     *                         properties on the first level can also be accessed without this format
     *                         $this->get('[foo]'), $this->get('foo')
     *
     * @return mixed the property value
     */
    public function get($property)
    {
        // property without PropertyAccesFormat given?
        if (strpos($property, '[') === false) {
            return array_key_exists($property, $this->configuration)? $this->configuration[$property] : null;
        }

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
        if (strpos($property, '[') === false) {
            $this->configuration[$property] = $value;
            return;
        }

        $this->accessor->setValue($this->configuration, $property, $value);
    }
}
