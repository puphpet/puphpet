<?php

namespace Puphpet\Plugins\Symfony\Configuration;

use Puphpet\Domain\Configuration\Configuration;
use Puphpet\Domain\Configuration\ConfigurationBuilderInterface;
use Puphpet\Domain\Configuration\Edition;
use Puphpet\Domain\Filesystem;

/**
 * Builds configuration for an optimized Symfony box.
 * This is currently a prototype and many things are hardcoded.
 * In the next steps this logic will be extended and moved to configuration.
 */
class SymfonyConfigurationBuilder implements ConfigurationBuilderInterface
{
    /**
     * @var string
     */
    private $bashAliasFile;

    /**
     * @var Filesystem
     */
    private $filesystem;

    /**
     * @param string     $bashAliasFile absolute path to bashalias file
     * @param Filesystem $filesystem
     */
    public function __construct($bashAliasFile, Filesystem $filesystem)
    {
        $this->bashAliasFile = $bashAliasFile;
        $this->filesystem = $filesystem;
    }

    /**
     * @param Edition $edition
     * @param array   $customConfiguration
     *
     * @return Configuration
     */
    public function build(Edition $edition, array $customConfiguration)
    {

        $projectName = $customConfiguration['project']['name'];
        $documentRoot = $customConfiguration['project']['document_root'];

        // calculate document root parent
        // example: /var/www/project/web -> parent is /var/www
        $parts = explode('/', str_replace('/web', '', $documentRoot));
        array_pop($parts);
        $documentRootParent = implode('/', $parts);

        $dbuser = 'guest';
        $dbpassword = 'guest';
        $dbname = 'symfony';

        $conf = array();

        // project settings
        $conf['project'] = array();
        $conf['project']['edition'] = $edition->getName();

        $conf['project']['generate'] = array_key_exists(
            'generate_project',
            $customConfiguration['project']
        ) ? $customConfiguration['project']['generate_project'] : false;
        $conf['project']['version'] = $customConfiguration['project']['symfony_version'];
        $conf['project']['document_root'] = $documentRoot;
        $conf['project']['document_root_parent'] = $documentRootParent;
        $conf['project']['name'] = $projectName;

        // box stuff
        $providerType = $edition->get('[provider][type]');
        $box = $edition->get('box');
        $box['personal_name'] = $projectName;
        $conf['provider'] = $edition->get('provider');

        $conf['provider'][$providerType] = array_merge(
            $conf['provider'][$providerType],
            $box,
            $customConfiguration['provider'][$providerType]
        );

        $conf['server'] = $edition->get('server');
        $conf['server']['bashaliases'] = $this->filesystem->getContents($this->bashAliasFile);

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
                    'user'       => $dbuser,
                    'password'   => $dbpassword,
                    'dbname'     => $dbname,
                    'host'       => 'localhost'
                ]
            ];
        } elseif ('postgresql' == $database) {
            $conf['postgresql'] = [
                'root'   => 'root',
                'dbuser' => [
                    'privileges' => ['ALL'],
                    'user'       => $dbuser,
                    'password'   => $dbpassword,
                    'dbname'     => $dbname,
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
                        'envvars'       => sprintf(
                            'SYMFONY__DATABASE__USER %s,SYMFONY__DATABASE__PASSWORD %s',
                            $dbuser,
                            $dbpassword
                        )
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
