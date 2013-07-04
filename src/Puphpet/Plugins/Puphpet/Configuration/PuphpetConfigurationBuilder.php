<?php

namespace Puphpet\Plugins\Puphpet\Configuration;

use Puphpet\Domain\Configuration\Configuration;
use Puphpet\Domain\Configuration\ConfigurationBuilderInterface;
use Puphpet\Domain\Configuration\Edition;

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
     * @param string $bashAliasFile absolute path to bashalias file
     */
    public function __construct($bashAliasFile)
    {
        $this->bashAliasFile = $bashAliasFile;
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
        $conf['project']['edition'] = $edition->getName();
        $conf['project']['document_root'] = $documentRoot;

        // box stuff
        $box = $edition->get('box');
        $box['personal_name'] = $projectName;
        $conf['box'] = array_merge($box, $customConfiguration['box']);

        $conf['server'] = $edition->get('server');
        $conf['server']['bashaliases'] = file_get_contents($this->bashAliasFile);

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