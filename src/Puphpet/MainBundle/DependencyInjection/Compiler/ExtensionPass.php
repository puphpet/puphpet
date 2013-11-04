<?php

namespace Puphpet\MainBundle\DependencyInjection\Compiler;

use Symfony\Component\DependencyInjection\Compiler\CompilerPassInterface;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Reference;

class ExtensionPass implements CompilerPassInterface
{
    /**
     * You can modify the container here before it is dumped to PHP code.
     *
     * @param ContainerBuilder $container
     */
    public function process(ContainerBuilder $container)
    {
        $manager = $container->getDefinition('puphpet.extension.manager');

        $extensions = [];

        // find all extensions by tag "puphpet.extension" and map them to the tmp priority list
        foreach ($container->findTaggedServiceIds('puphpet.extension') as $id => $attributes) {
            $priority = isset($attributes[0]['priority']) ? $attributes[0]['priority'] : 0;
            $group = isset($attributes[0]['group']) ? $attributes[0]['group'] : false;

            if ($group) {
                $extensions[$priority][] = ['group' => $group, 'extension' => new Reference($id)];
            } else {
                $extensions[$priority][] = new Reference($id);
            }
        }

        // priority list is sorted now so priority defined in the tags is taken to effect
        // services with a higher prio will be added first (100>50)
        krsort($extensions);

        // sorted extensions could be added to extension manager now either with "addExtensionToGroup"
        // or "addExtension"
        foreach ($extensions as $extensionRow) {
            foreach ($extensionRow as $extension) {
                if (is_array($extension)) {
                    $manager->addMethodCall('addExtensionToGroup', array($extension['group'], $extension['extension']));
                } else {
                    $manager->addMethodCall('addExtension', array($extension));
                }
            }
        }
    }
}
