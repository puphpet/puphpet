<?php

namespace Puphpet\Tests;

use Silex\WebTestCase;
use Silex\Application;

abstract class Base extends WebTestCase
{
    /** @var Application */
    protected $app;

    public function createApplication()
    {
        // Silex
        $this->app = require __DIR__ . '/../../../src/App.php';

        // Tests mode
        $this->app['debug'] = true;
        $this->app['exception_handler']->disable();

        return $this->app;
    }

    /**
     * Set protected/private attribute of object
     *
     * @param object &$object       Object containing attribute
     * @param string $attributeName Attribute name to change
     * @param string $value         Value to set attribute to
     *
     * @return null
     */
    public function setAttribute(&$object, $attributeName, $value)
    {
        $class = is_object($object) ? get_class($object) : $object;

        $reflection = new \ReflectionProperty($class, $attributeName);
        $reflection->setAccessible(true);
        $reflection->setValue($object, $value);
    }

    /**
     * Get protected/private attribute of object
     *
     * @param  object &$object       Object containing attribute
     * @param  string $attributeName Attribute name to fetch
     * @return mixed
     */
    public function getAttribute(&$object, $attributeName)
    {
        $class = is_object($object) ? get_class($object) : $object;

        $reflection = new \ReflectionProperty($class, $attributeName);
        $reflection->setAccessible(true);

        return $reflection->getValue($object);
    }

    /**
     * Call protected/private method of a class.
     *
     * @param object &$object    Instantiated object that we will run method on.
     * @param string $methodName Method name to call
     * @param array  $parameters Array of parameters to pass into method.
     *
     * @return mixed Method return.
     */
    public function invokeMethod(&$object, $methodName, array $parameters = array())
    {
        $reflection = new \ReflectionClass(get_class($object));
        $method = $reflection->getMethod($methodName);
        $method->setAccessible(true);

        return $method->invokeArgs($object, $parameters);
    }
}
