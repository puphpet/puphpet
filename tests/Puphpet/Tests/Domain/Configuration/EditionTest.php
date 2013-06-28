<?php

namespace Puphpet\Tests\Domain\Configuration;

use Puphpet\Domain\Configuration\Edition;

class EditionTest extends \PHPUnit_Framework_TestCase
{
    public function testGetCallsPropertyAccessor()
    {
        $property = 'foo';
        $propertyAccess = '[foo]';
        $value = 'bar';

        $configuration = [$property => $value];

        $accessor = $this->buildAccessor();
        $accessor->expects($this->once())
            ->method('getValue')
            ->with($configuration, $propertyAccess)
            ->will($this->returnValue($value));

        $edition = new Edition($this->buildPropertyAccessProvider($accessor));
        $edition->setConfiguration($configuration);
        $result = $edition->get($propertyAccess);

        $this->assertEquals($value, $result);
    }

    public function testGetterWithoutAccessor()
    {
        $property = 'foo';
        $value = 'bar';

        $configuration = [$property => $value];

        $accessor = $this->buildAccessor();
        $accessor->expects($this->never())
            ->method('getValue');

        $edition = new Edition($this->buildPropertyAccessProvider($accessor));
        $edition->setConfiguration($configuration);
        $result = $edition->get($property);

        $this->assertEquals($value, $result);
    }

    public function testSetCallsPropertyAccessor()
    {
        $property = 'foo';
        $propertyAccess = '[foo]';
        $value = 'bar';

        $configuration = [$property => $value];

        $accessor = $this->buildAccessor();
        $accessor->expects($this->once())
            ->method('setValue')
            ->with($configuration, $propertyAccess, $value);

        $edition = new Edition($this->buildPropertyAccessProvider($accessor));
        $edition->setConfiguration($configuration);
        $edition->set($propertyAccess, $value);
    }

    public function testConfigurationAccess()
    {
        $accessor = $this->getMockBuilder('Symfony\Component\PropertyAccess\PropertyAccessor')
            ->disableOriginalConstructor()
            ->setMethods(array())
            ->getMock();

        $configuration = ['foo' => 'bar'];

        $edition = new Edition($this->buildPropertyAccessProvider($accessor));
        $edition->setConfiguration($configuration);
        $this->assertEquals($configuration, $edition->getConfiguration());
    }

    public function testSetGet()
    {
        $accessor = $this->getMockBuilder('Symfony\Component\PropertyAccess\PropertyAccessor')
            ->disableOriginalConstructor()
            ->setMethods(array())
            ->getMock();
        $name = 'foo';

        $edition = new Edition($this->buildPropertyAccessProvider($accessor));
        $edition->setName($name);
        $this->assertEquals($name, $edition->getName());
    }

    /**
     * @param PHPUnit_Framework_MockObject_MockObject $accessor
     *
     * @return \PHPUnit_Framework_MockObject_MockObject
     */
    private function buildPropertyAccessProvider($accessor)
    {
        $provider = $this->getMockBuilder('Puphpet\Domain\Configuration\PropertyAccessProvider')
            ->disableOriginalConstructor()
            ->setMethods(['provide'])
            ->getMock();

        $provider->expects($this->once())
            ->method('provide')
            ->will($this->returnValue($accessor));

        return $provider;
    }

    private function buildAccessor()
    {
        return $this->getMockBuilder('Symfony\Component\PropertyAccess\PropertyAccessor')
            ->disableOriginalConstructor()
            ->setMethods(['setValue', 'getValue'])
            ->getMock();
    }
}
