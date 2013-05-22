<?php

namespace Puphpet\Tests\Domain\PuppetModule;

use Puphpet\Domain\Compiler\Compiler;

class CompilerTest extends \PHPUnit_Framework_TestCase
{
    public function testCompile()
    {
        $template = '/foo/bar.twig';
        $configuration = ['foo' => 'bar'];
        $rendered = 'hello world';

        $twig = $this->getMockBuilder('\Twig_Environment')
          ->disableOriginalConstructor()
          ->setMethods(['render'])
          ->getMock();

        $twig->expects($this->once())
            ->method('render')
            ->with($template, $configuration)
            ->will($this->returnValue($rendered));

        $compiler = new Compiler($twig, $template);
        $result = $compiler->compile($configuration);

        $this->assertEquals($rendered, $result);
    }
}
