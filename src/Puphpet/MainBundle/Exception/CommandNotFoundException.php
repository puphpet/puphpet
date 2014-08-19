<?php
/**
 * Created by PhpStorm.
 * User: rolfst
 * Date: 19-8-14
 * Time: 13:24
 */

namespace Puphpet\MainBundle\Exception;



/**
 * Class CommandNotFoundException
 * Exception in case a command is not found on the OS
 * @package Puphpet\MainBundle\Exceptions
 */
class CommandNotFoundException extends \RuntimeException implements OSException {

    public function __construct($message = "Command not found, missing program", $code="127"){
        parent::__construct($message, $code);
    }

} 