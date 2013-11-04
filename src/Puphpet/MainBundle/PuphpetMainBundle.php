<?php

namespace Puphpet\MainBundle;

use Puphpet\MainBundle\DependencyInjection\Compiler\ExtensionPass;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\HttpKernel\Bundle\Bundle;

class PuphpetMainBundle extends Bundle
{
    public function build(ContainerBuilder $container)
    {
        $container->addCompilerPass(new ExtensionPass());
    }
}
