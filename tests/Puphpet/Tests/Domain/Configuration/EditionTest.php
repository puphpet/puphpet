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

        $accessor = $this->getMockBuilder('Symfony\Component\PropertyAccess\PropertyAccessor')
            ->disableOriginalConstructor()
            ->setMethods(['getValue'])
            ->getMock();

        $accessor->expects($this->once())
            ->method('getValue')
            ->with($configuration, $propertyAccess)
            ->will($this->returnValue($value));

        $edition = new Edition($this->buildPropertyAccessProvider($accessor));
        $edition->setConfiguration($configuration);
        $result = $edition->get($propertyAccess);

        $this->assertEquals($value, $result);
    }

    public function testSetCallsPropertyAccessor()
    {
        $property = 'foo';
        $propertyAccess = '[foo]';
        $value = 'bar';

        $configuration = [$property => $value];

        $accessor = $this->getMockBuilder('Symfony\Component\PropertyAccess\PropertyAccessor')
            ->disableOriginalConstructor()
            ->setMethods(['setValue'])
            ->getMock();

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
}
