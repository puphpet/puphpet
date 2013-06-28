<?php

namespace Puphpet\Plugins\Symfony\Configuration;

use Puphpet\Domain\Configuration\Configuration;
use Puphpet\Domain\Configuration\ConfigurationBuilderInterface;
use Puphpet\Domain\Configuration\Edition;

/**
 * Builds configuration for an optimized Symfony box.
 * This is currently a prototype and many things are hardcoded.
 * In the next steps this logic will be extended and moved to configuration.
 */
class SymfonyConfigurationBuilder implements ConfigurationBuilderInterface
{

    public function build(Edition $edition, array $customConfiguration)
    {
        $projectName = $customConfiguration['project']['name'];
        $documentRoot = '/var/www/' . $projectName;

        $conf = array();

        // project settings
        $conf['project'] = array();
        $conf['project']['edition'] = $edition->getName();
        /*
         * tmp deactivated
        $conf['project']['generate'] = array_key_exists(
            'generate_project',
            $customConfiguration['project']
        ) ? $customConfiguration['project']['generate_project'] : false;
        $conf['project']['version'] = $customConfiguration['project']['symfony_version'];
        */
        $conf['project']['document_root'] = $documentRoot;

        // box stuff
        $conf['box'] = $customConfiguration['box'];
        $conf['box']['personal_name'] = $projectName;
        $conf['box']['ip'] = '192.168.56.101';
        $conf['box']['memory'] = '1024';
        $conf['box']['foldertype'] = 'default';
        $conf['box']['synced_folder'] = ['source' => './', 'target' => '/var/www'];
        $conf['box']['port_forward'] = ['host' => false, 'guest' => false];

        $conf['server'] = array();
        $conf['server']['packages'] = 'build-essential,vim,curl';

        $conf['php'] = $edition->get('[php]');
        $conf['php']['version'] = $customConfiguration['php']['version'];

        $webserver = $customConfiguration['webserver'];
        $database = $customConfiguration['database'];
        $conf['webserver'] = $webserver;
        $conf['database'] = $database;

        if ('mysql' == $database) {
            $conf['mysql'] = [
                'root'       => 'root',
                'phpmyadmin' => $customConfiguration['mysql']['phpmyadmin'],
                'dbuser'     => [
                    'privileges' => ['ALL'],
                    'user'       => 'guest',
                    'password'   => 'guest',
                    'dbname'     => 'symfony',
                    'host'       => 'localhost'
                ]
            ];
        } elseif ('postgresql' == $database) {
            $conf['postgresql'] = [
                'root'   => 'root',
                'dbuser' => [
                    'privileges' => ['ALL'],
                    'user'       => 'guest',
                    'password'   => 'guest',
                    'dbname'     => 'symfony',
                ]
            ];
        }

        if ('nginx' == $webserver) {
            $conf['nginx'] = [
                'vhosts' => [
                    [
                        'servername'    => $projectName,
                        'serveraliases' => 'www.' . $projectName,
                        'docroot'       => $documentRoot,
                        'port'          => 80,
                        'index_files'   => ['index.html', 'index.htm', 'index.php'],
                        'envvars'       => 'SYMFONY__DATABASE__USER guest,SYMFONY__DATABASE__PASSWORD guest'
                    ]
                ]
            ];
        } else {
            $conf['apache'] = [
                'modules' => ['rewrite'],
                'vhosts'  => [
                    [
                        'servername'    => $projectName,
                        'serveraliases' => 'www.' . $projectName,
                        'docroot'       => $documentRoot,
                        'port'          => 80,
                        'index_files'   => ['index.html', 'index.htm', 'index.php'],
                        'envvars'       => 'SYMFONY__DATABASE__USER guest,SYMFONY__DATABASE__PASSWORD guest'
                    ]
                ]
            ];


        }

        return new Configuration($conf);
    }
}