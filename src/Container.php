<?php

use jtreminio\Zimple\Zimple;
use \Silex\Application;

class Container extends Zimple
{
    /** @var $app Application */
    private $app;

    /**
     * Return Silex app
     *
     * @return Application
     */
    public function getApp()
    {
        if (!$this->app) {
            $this->app = $this->setApp();
        }

        return $this->app;
    }

    /**
     * Initial setup of app
     *
     * @return Application
     */
    protected function setApp()
    {
        return new Application;
    }
}
