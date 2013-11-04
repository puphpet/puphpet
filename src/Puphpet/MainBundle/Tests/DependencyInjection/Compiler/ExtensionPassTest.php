<?php

namespace Puphpet\MainBundle\Tests\DependencyInjection\Compiler;

use Puphpet\MainBundle\DependencyInjection\Compiler\ExtensionPass;
use Symfony\Component\DependencyInjection\Reference;

class ExtensionPassTest extends \PHPUnit_Framework_TestCase
{
    public function testProcess()
    {
        // mixed order, priority value is important
        $tags = [
            'extension_group_200' => [['name' => 'puphpet.extension', 'group' => 'foo', 'priority' => 200]],
            'extension_group_400' => [['name' => 'puphpet.extension', 'group' => 'foo', 'priority' => 400]],
            'extension_300'       => [['name' => 'puphpet.extension', 'priority' => 300]],
            'extension_100'       => [['name' => 'puphpet.extension', 'priority' => 100]],
        ];

        // the manager definition should recieve 4 extensions
        // 2 groups and 2 normal ones
        $manager = $this->getMockBuilder('\Symfony\Component\DependencyInjection\Definition')
            ->disableOriginalConstructor()
            ->setMethods(['addMethodCall'])
            ->getMock();

        $manager->expects($this->at(0))
            ->method('addMethodCall')
            ->with('addExtensionToGroup', ['foo', $this->buildReference('extension_group_400')]);

        $manager->expects($this->at(1))
            ->method('addMethodCall')
            ->with('addExtension', [$this->buildReference('extension_300')]);

        $manager->expects($this->at(2))
            ->method('addMethodCall')
            ->with('addExtensionToGroup', ['foo', $this->buildReference('extension_group_200')]);

        $manager->expects($this->at(3))
            ->method('addMethodCall')
            ->with('addExtension', [$this->buildReference('extension_100')]);


        // the ContainerBuilder has to return all tagged services
        $container = $this->getMockBuilder('\Symfony\Component\DependencyInjection\ContainerBuilder')
            ->disableOriginalConstructor()
            ->setMethods(['findTaggedServiceIds', 'getDefinition'])
            ->getMock();

        $container->expects($this->once())
            ->method('getDefinition')
            ->will($this->returnValue($manager));

        $container->expects($this->once())
            ->method('findTaggedServiceIds')
            ->with('puphpet.extension')
            ->will($this->returnValue($tags));


        $pass = new ExtensionPass();
        $pass->process($container);
    }

    private function buildReference($id)
    {
        // couldn't be mocked properly :/ otherwise comparison will fail
        return new Reference($id);
    }
}
