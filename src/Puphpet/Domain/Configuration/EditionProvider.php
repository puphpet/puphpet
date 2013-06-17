<?php

namespace Puphpet\Domain\Configuration;

class EditionProvider {

    /**
     * @var Edition
     */
    private $edition;

    /**
     * @var array
     */
    private $availableEditions;

    /**
     * @var string
     */
    private $defaultEditionName;

    /**
     * @param Edition $edition
     * @param array   $availableEditions
     * @param string  $defaultEditionName
     */
    public function __construct(Edition $edition, array $availableEditions, $defaultEditionName)
    {
        $this->edition = $edition;
        $this->availableEditions = $availableEditions;
        $this->defaultEditionName = $defaultEditionName;
    }

    /**
     * @param string $editionName
     *
     * @return Edition
     */
    public function provide($editionName)
    {
        // validate edition name
        // use fallback if invalid edition name is requested (better than throwing any error)
        if (!array_key_exists($editionName, $this->availableEditions)) {
            $editionName = $this->defaultEditionName;
        }

        // fill the edition entity with requested configuration
        /**@var $edition \PuPHPet\Domain\Configuration\Edition */
        $edition = $this->edition;
        $edition->setName($editionName);
        $edition->setConfiguration($this->availableEditions[$editionName]);

        return $edition;
    }
}