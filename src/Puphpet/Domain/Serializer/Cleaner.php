<?php

namespace Puphpet\Domain\Serializer;

class Cleaner
{
    public function clean($deserialized)
    {
        // only removes elements on the first level

        // strip out all elements like "php-inilist-name-xdebug"
        // they are needed within the form but not within the system
        foreach ($deserialized as $key => $value) {
            if (strpos($key, 'php-inilist-') !== false) {
                unset($deserialized[$key]);
            }
        }


        return $this->cleanPasswordFields($deserialized);
    }

    /**
     * Strips out non-empty password values
     *
     * @param array $data
     *
     * @return array
     */
    private function cleanPasswordFields(array $data)
    {
        foreach ($data as $key => $value) {
            if (is_array($value)) {
                $data[$key] = $this->cleanPasswordFields($value);
            } else {

                if (strpos($key, 'password') !== false || $key === 'root') {
                    // we have to know lateron if a password field was set by the user
                    // or if it really was empty
                    $data[$key] = empty($value) ? $value : '<REMOVED>';
                } else {
                    $data[$key] = $value;
                }
            }
        }

        return $data;
    }
}
