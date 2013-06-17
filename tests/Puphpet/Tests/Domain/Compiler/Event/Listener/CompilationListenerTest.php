<?php

namespace Puphpet\Tests\Domain\Compiler\Event\Listener;

use Puphpet\Domain\Compiler\Event\Listener\CompilationListener;

class CompilerTest extends \PHPUnit_Framework_TestCase
{
    public function testOnCompile()
    {
        $compilation = $this->getMockBuilder('Puphpet\Domain\Compiler\Compilation')
            ->setMethods([])
            ->getMock();

        $event = $this->getMockBuilder('Puphpet\Domain\Compiler\Event\CompilationEvent')
            ->disableOriginalConstructor()
            ->setMethods(['getCompilation'])
            ->getMock();

        $event->expects($this->once())
            ->method('getCompilation')
            ->will($this->returnValue($compilation));

        $manipulator = $this->getMockBuilder('Puphpet\Domain\Compiler\ManipulatorInterface')
            ->setMethods(['manipulate'])
            ->getMock();

        $manipulator->expects($this->once())
            ->method('manipulate')
            ->with($compilation);

        $listener = new CompilationListener($manipulator);
        $listener->onCompile($event);
    }
}
