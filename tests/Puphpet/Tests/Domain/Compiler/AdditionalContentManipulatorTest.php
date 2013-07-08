<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\Compiler\AdditionalContentManipulator;

class AdditionalContentManipulatorTest extends \PHPUnit_Framework_TestCase
{
    public function testSupportsReturnsFalse()
    {
        $configuration = ['foo' => 'bar'];
        $compilation = $this->buildCompilation($configuration);
        $twig = $this->buildTwig();
        $template = 'foo';

        $decider = $this->buildDecider();
        $decider->expects($this->once())
            ->method('supports')
            ->with($configuration)
            ->will($this->returnValue(false));

        $manipulator = new AdditionalContentManipulator($decider, $twig, $template);
        $this->assertFalse($manipulator->supports($compilation));
    }

    public function testSupportsReturnsTrue()
    {
        $configuration = ['foo' => 'bar'];
        $compilation = $this->buildCompilation($configuration);
        $twig = $this->buildTwig();
        $template = 'foo';

        $decider = $this->buildDecider();
        $decider->expects($this->once())
            ->method('supports')
            ->with($configuration)
            ->will($this->returnValue(true));

        $manipulator = new AdditionalContentManipulator($decider, $twig, $template);
        $this->assertTrue($manipulator->supports($compilation));
    }

    public function testManipulate()
    {
        $configuration = ['foo' => 'bar'];
        $template = 'foo';
        $rendered = 'rendered';
        $compilation = $this->buildCompilation($configuration);
        $compilation->expects($this->once())
            ->method('addContent')
            ->with($rendered);

        $twig = $this->buildTwig();
        $twig->expects($this->once())
            ->method('render')
            ->with($template, $configuration)
            ->will($this->returnValue($rendered));

        $decider = $this->buildDecider();

        $manipulator = new AdditionalContentManipulator($decider, $twig, $template);
        $manipulator->manipulate($compilation);
    }

    private function buildDecider()
    {
        return $this->getMockForAbstractClass('Puphpet\Domain\Decider\DeciderInterface');
    }

    private function buildCompilation($configuration)
    {
        $compilation = $this->getMockBuilder('Puphpet\Domain\Compiler\Compilation')
            ->disableOriginalConstructor()
            ->setMethods(['getConfiguration', 'addContent'])
            ->getMock();

        $compilation->expects($this->once())
            ->method('getConfiguration')
            ->will($this->returnValue($configuration));

        return $compilation;

    }

    private function buildTwig()
    {
        return $this->getMockBuilder('\Twig_Environment')
            ->disableOriginalConstructor()
            ->setMethods(['render'])
            ->getMock();
    }
}
