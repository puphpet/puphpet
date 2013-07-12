<?php

namespace Puphpet\Domain\Serializer;

/*
 * (De)-Serializer for box configuration
 */
class Serializer
{
    /**
     * @var Cleaner
     */
    private $cleaner;

    /**
     * @param Cleaner $cleaner
     */
    public function __construct(Cleaner $cleaner)
    {
        $this->cleaner = $cleaner;
    }

    /**
     * @param array $deserialized
     *
     * @return string
     */
    public function serialize(array $deserialized)
    {
        return json_encode($this->cleanDeserialized($deserialized), JSON_PRETTY_PRINT);
    }

    /**
     * @param string $serialized
     *
     * @return array
     */
    public function deserialize($serialized)
    {
        return json_decode($serialized, true);
    }

    /**
     * @param array $deserialized
     *
     * @return array
     */
    private function cleanDeserialized(array $deserialized)
    {
        return $this->cleaner->clean($deserialized);
    }
}
