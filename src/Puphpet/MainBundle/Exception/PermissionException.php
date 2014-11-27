<?php
/**
 * Created by PhpStorm.
 * User: rolfst
 * Date: 19-8-14
 * Time: 13:44
 */

namespace Puphpet\MainBundle\Exception;


/**
 * Class PermissionException
 * Exception incase an operation is not allowed by the OS.
 * @package Puphpet\MainBundle\Exceptions
 */
class PermissionException extends \RuntimeException implements OSException {
    public function __construct($message="Permission denied", $code="126") {
        parent::__construct($message, $code);
    }
} 