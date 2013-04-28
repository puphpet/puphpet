<?php

use Puphpet\Controller;

/** @var \Silex\Application $app */
$app->mount('/', new Puphpet\Controller\Front($app));
