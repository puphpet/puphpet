<?php

namespace Puphpet\Extension\VagrantfileLocalBundle\EventListener;

use Puphpet\MainBundle\EventListener\MixinConfigurationListener;

class HostnameMixinListener extends MixinConfigurationListener
{
    /**
     * {@inheritdoc}
     */
    protected function supports(array $configuration)
    {
        return (isset($configuration['apache']) || isset($configuration['nginx']));
    }

    /**
     * Extracts the hostname/servername of the first vhost and takes this value
     * for the box's hostname.
     *
     * {@inheritdoc}
     */
    protected function mixin(array $configuration, array $data)
    {
        $hostname = null;

        if (isset($configuration['apache'])) {
            $vhosts = $configuration['apache']['vhosts'];
            $firstVhost = current($vhosts);
            $hostname = $firstVhost['servername'];
        } elseif (isset($configuration['nginx'])) {
            $vhosts = $configuration['nginx']['vhosts'];
            $firstVhost = current($vhosts);
            $hostname = $firstVhost['servername'];
        }

        if ($hostname) {
            $data['vm']['hostname'] = $hostname;
        }

        return $data;
    }
}
