<?php

namespace Puphpet\Extension\PhpBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract implements Extension\ExtensionInterface
{
    public function getName()
    {
        return 'Php';
    }

    public function getController()
    {
        return $this->container->get('puphpet.extension.php.main_controller');
    }
}
