<?php

namespace Puphpet\Extension\ApacheBundle;

use Puphpet\MainBundle\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface as Container;

class Configure extends Extension\ExtensionAbstract
{
    protected $name = 'Apache';
    protected $slug = 'apache';
    protected $targetFile = 'puppet/manifests/default.pp';

    protected $sources = [
        'apache' => ":git => 'git://github.com/puphpet/puppetlabs-apache.git'",
    ];

    /**
     * @param Container $container
     */
    public function __construct(Container $container)
    {
        $this->dataLocation = __DIR__ . '/Resources/config';

        parent::__construct($container);
    }

    public function getFrontController()
    {
        return $this->container->get('puphpet.extension.apache.front_controller');
    }

    public function getManifestController()
    {
        return $this->container->get('puphpet.extension.apache.manifest_controller');
    }

    /**
     * @inheritdoc
     */
    public function getData()
    {
        $data = parent::getData();
        $data = $this->fixVhosts($data);

        return $data;
    }

    /**
     * @param array $data
     *
     * @return array
     */
    protected function fixVhosts(array $data)
    {
        foreach ($data['vhosts'] as $id => $vhost) {
            $ssl = $vhost['ssl'];

            // "http" vhost should be doubled
            if ($ssl === '1') {
                // reset original vhost
                $data['vhosts'][$id]['ssl'] = false;

                // clone vhost and add ssl version
                $sslVhost = $this->generateSslVhost($vhost);
                $sslId = $id . '_ssl';

                // add ssl vhost only if it does not exist already
                if (!array_key_exists($sslId, $data)) {
                    $data['vhosts'][$sslId] = $sslVhost;
                }
            } elseif ($ssl === '2') { // ssl only
                $data['vhosts'][$id]['ssl'] = true;
            } else {
                $data['vhosts'][$id]['ssl'] = false;
            }
        }

        return $data;
    }

    /**
     * @param array $sslVhost
     *
     * @return array
     */
    protected function generateSslVhost(array $sslVhost)
    {
        $sslVhost['port'] = 443;
        $sslVhost['ssl'] = true;

        return $sslVhost;
    }
}
