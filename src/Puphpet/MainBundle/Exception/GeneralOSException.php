<?php
/**
 * Created by PhpStorm.
 * User: rolfst
 * Date: 19-8-14
 * Time: 13:46
 */

namespace Puphpet\MainBundle\Exception;


/**
 * Class GeneralOSException
 * @package Puphpet\MainBundle\Exception
 */
class GeneralOSException extends \RuntimeException implements OSException{

    public function __construct($message="Unknown OS exception", $code="1"){
        parent::__construct($message, $code);
    }
} 