<?php

namespace Puphpet\Extension\ServerBasicsBundle;

use Puphpet\MainBundle\Extension;

class Configure extends Extension\ExtensionAbstract implements Extension\ExtensionInterface
{
    public function getName()
    {
        return 'Server Basics';
    }

    public function getController()
    {
        return $this->container->get('puphpet.extension.server_basics.main_controller');
    }
}
