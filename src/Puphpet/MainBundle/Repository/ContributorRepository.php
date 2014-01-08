<?php

namespace Puphpet\MainBundle\Repository;

class ContributorRepository
{
    private $targetUrl;

    /**
     * @param string $targetUrl the github target url providing all contributors
     */
    public function __construct($targetUrl)
    {
        $this->targetUrl = $targetUrl;
    }

    /**
     * Returns a list of all contributors
     *
     * @return array
     */
    public function findAll()
    {
        return json_decode($this->get($this->targetUrl), true);
    }

    /**
     * Does a simple GET request on given url
     *
     * @param string $url
     *
     * @return string
     */
    protected function get($url)
    {
        // curl could be replaced by any high level transport layer like Buzz or Guzzle

        // create a new cURL resource
        $ch = curl_init();

        // set URL and other appropriate options
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        // grab URL and pass it to the browser
        $response = curl_exec($ch);

        // close cURL resource, and free up system resources
        curl_close($ch);

        return $response;
    }
}
