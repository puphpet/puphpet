<?php

namespace Puphpet\Plugins\Symfony\Compiler;

use Puphpet\Domain\Compiler\DeciderInterface;
use Puphpet\Domain\Configuration\PropertyAccessProvider;

/**
 * Decides if Symfony project should be generated (not as easy without a solid domain model)
 */
class SymfonyCreateProjectDecider implements DeciderInterface
{
    /**
     * @var PropertyAccessProvider
     */
    private $provider;

    /**
     * @var string
     */
    private $editionIdentifier;

    /**
     * @param PropertyAccessProvider $provider
     * @param string                 $editionIdentifier
     */
    public function __construct(PropertyAccessProvider $provider, $editionIdentifier = 'symfony')
    {
        $this->provider = $provider;
        $this->editionIdentifier = $editionIdentifier;
    }

    /**
     * @param array $configuration
     *
     * @return bool
     */
    public function supports(array &$configuration)
    {
        $propertyAccess = $this->provider->provide();
        if ($this->editionIdentifier == $propertyAccess->getValue($configuration, '[project][edition]')) {

            return (bool)$propertyAccess->getValue($configuration, '[project][generate]');
        }

        return false;
    }
}
