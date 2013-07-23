<?php

namespace Puphpet\Plugins\Puphpet\Configuration;

use Puphpet\Domain\Configuration\Configuration;
use Puphpet\Domain\Configuration\ConfigurationBuilderInterface;
use Puphpet\Domain\Configuration\Edition;
use Puphpet\Domain\Filesystem;

/**
 * Builds configuration for an optimized Puphpet development box.
 */
class PuphpetConfigurationBuilder implements ConfigurationBuilderInterface
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
     * @param string $bashAliasFile absolute path to bashalias file
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
        $projectName = 'puphpet.dev';
        $documentRoot = '/var/www/' . $projectName . '/web';

        $conf = array();

        // project settings
        $conf['project'] = array();
        $conf['project']['name'] = $projectName;
        $conf['project']['edition'] = $edition->getName();
        $conf['project']['document_root'] = $documentRoot;

        // box stuff
        // BC
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

        $conf['php'] = $edition->get('php');
        $conf['webserver'] = 'apache';
        $conf['database'] = false;

        $conf['apache'] = [
            'modules' => ['rewrite'],
            'vhosts'  => [
                [
                    'servername'    => $projectName,
                    'serveraliases' => 'www.' . $projectName,
                    'docroot'       => $documentRoot,
                    'port'          => 80,
                    'index_files'   => ['index.html', 'index.htm', 'index.php'],
                ]
            ]
        ];

        return new Configuration($conf);
    }
}
