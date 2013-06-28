<?php

namespace Puphpet\Tests\Domain;

use Puphpet\Plugins\Symfony\Compiler\SymfonyCreateProjectDecider;

class SymfonyCreateProjectDeciderTest extends \PHPUnit_Framework_TestCase
{

    public function testDecideReturnsTrueWithSupported()
    {
        $configuration = ['project' => ['edition' => 'symfony', 'generate' => true]];

        $accessor = $this->getMockBuilder('Symfony\Component\PropertyAccess\PropertyAccessor')
            ->disableOriginalConstructor()
            ->setMethods(['getValue'])
            ->getMock();

        $accessor->expects($this->at(0))
            ->method('getValue')
            ->with($configuration, '[project][edition]')
            ->will($this->returnValue('symfony'));

        $accessor->expects($this->at(1))
            ->method('getValue')
            ->with($configuration, '[project][generate]')
            ->will($this->returnValue(true));

        $provider = $this->buildPropertyAccessProvider($accessor);

        $manipulator = new SymfonyCreateProjectDecider($provider);
        $this->assertTrue($manipulator->supports($configuration));
    }

    public function testDecideReturnsFalseWithUnsupported()
    {
        $configuration = ['dum' => 'my'];

        $accessor = $this->getMockBuilder('Symfony\Component\PropertyAccess\PropertyAccessor')
            ->disableOriginalConstructor()
            ->setMethods(['getValue'])
            ->getMock();

        $accessor->expects($this->once())
            ->method('getValue')
            ->with($configuration, '[project][edition]')
            ->will($this->returnValue('unsupported'));

        $provider = $this->buildPropertyAccessProvider($accessor);

        $manipulator = new SymfonyCreateProjectDecider($provider);
        $this->assertFalse($manipulator->supports($configuration));
    }

    public function testDecideReturnsFalseWhenProjectShouldNotBeGenerated()
    {
        $configuration = ['project' => ['edition' => 'symfony', 'generate' => false]];

        $accessor = $this->getMockBuilder('Symfony\Component\PropertyAccess\PropertyAccessor')
            ->disableOriginalConstructor()
            ->setMethods(['getValue'])
            ->getMock();

        $accessor->expects($this->at(0))
            ->method('getValue')
            ->with($configuration, '[project][edition]')
            ->will($this->returnValue('symfony'));

        $accessor->expects($this->at(1))
            ->method('getValue')
            ->with($configuration, '[project][generate]')
            ->will($this->returnValue(false));

        $provider = $this->buildPropertyAccessProvider($accessor);

        $manipulator = new SymfonyCreateProjectDecider($provider);
        $this->assertFalse($manipulator->supports($configuration));
    }

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
