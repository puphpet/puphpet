<?php

namespace Puphpet\Extension\ApacheBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract implements Extension\ExtensionInterface
{
    public function getName()
    {
        return 'Apache';
    }

    public function getController()
    {
        return $this->container->get('puphpet.extension.apache.main_controller');
    }
}
