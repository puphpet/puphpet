<?php

use Symfony\Component\HttpKernel\Kernel;
use Symfony\Component\Config\Loader\LoaderInterface;

class AppKernel extends Kernel
{
    public function registerBundles()
    {
        $bundles = array(
            new Symfony\Bundle\FrameworkBundle\FrameworkBundle(),
            new Symfony\Bundle\SecurityBundle\SecurityBundle(),
            new Symfony\Bundle\TwigBundle\TwigBundle(),
            new Symfony\Bundle\AsseticBundle\AsseticBundle(),
            new Sensio\Bundle\FrameworkExtraBundle\SensioFrameworkExtraBundle(),
            new Puphpet\MainBundle\PuphpetMainBundle(),
            new Cocur\Slugify\Bridge\Symfony\CocurSlugifyBundle(),

            new Puphpet\Extension\VagrantfileLocalBundle\PuphpetExtensionVagrantfileLocalBundle(),
            new Puphpet\Extension\VagrantfileDigitalOceanBundle\PuphpetExtensionVagrantfileDigitalOceanBundle(),
            new Puphpet\Extension\VagrantfileRackspaceBundle\PuphpetExtensionVagrantfileRackspaceBundle(),
            new Puphpet\Extension\VagrantfileAwsBundle\PuphpetExtensionVagrantfileAwsBundle(),
            new Puphpet\Extension\ServerBundle\PuphpetExtensionServerBundle(),
            new Puphpet\Extension\ApacheBundle\PuphpetExtensionApacheBundle(),
            new Puphpet\Extension\NginxBundle\PuphpetExtensionNginxBundle(),
            new Puphpet\Extension\PhpBundle\PuphpetExtensionPhpBundle(),
            new Puphpet\Extension\DrushBundle\PuphpetExtensionDrushBundle(),
            new Puphpet\Extension\XdebugBundle\PuphpetExtensionXdebugBundle(),
            new Puphpet\Extension\XhprofBundle\PuphpetExtensionXhprofBundle(),
            new Puphpet\Extension\MysqlBundle\PuphpetExtensionMysqlBundle(),
            new Puphpet\Extension\PostgresqlBundle\PuphpetExtensionPostgresqlBundle(),
            new Puphpet\Extension\MariaDbBundle\PuphpetExtensionMariaDbBundle(),
            new Puphpet\Extension\BeanstalkdBundle\PuphpetExtensionBeanstalkdBundle(),
            new Puphpet\Extension\MongoDbBundle\PuphpetExtensionMongoDbBundle(),
            new Puphpet\Extension\ElasticSearchBundle\PuphpetExtensionElasticSearchBundle(),
            new Puphpet\Extension\MailCatcherBundle\PuphpetExtensionMailCatcherBundle(),
            new Puphpet\Extension\RabbitMQBundle\PuphpetExtensionRabbitMQBundle(),
            new Puphpet\Extension\HhvmBundle\PuphpetExtensionHhvmBundle(),
            new Puphpet\Extension\RedisBundle\PuphpetExtensionRedisBundle(),
            new Puphpet\Extension\FirewallBundle\PuphpetExtensionFirewallBundle(),
        );

        if (in_array($this->getEnvironment(), array('dev', 'test'))) {
            $bundles[] = new Symfony\Bundle\WebProfilerBundle\WebProfilerBundle();
            $bundles[] = new Sensio\Bundle\DistributionBundle\SensioDistributionBundle();
            $bundles[] = new Sensio\Bundle\GeneratorBundle\SensioGeneratorBundle();
        }

        return $bundles;
    }

    public function registerContainerConfiguration(LoaderInterface $loader)
    {
        $loader->load(__DIR__.'/config/config_'.$this->getEnvironment().'.yml');
    }
}
