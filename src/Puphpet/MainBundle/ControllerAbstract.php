<?php

namespace Puphpet\MainBundle;

use Symfony\Bundle\FrameworkBundle\Controller\Controller as SymfonyController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

abstract class ControllerAbstract extends SymfonyController
{
    protected $viewParameters = [];

    /**
     * Renders a view.
     *
     * @param string   $view       The view name
     * @param array    $parameters An array of parameters to pass to the view
     * @param Response $response   A response instance
     *
     * @return Response A Response instance
     */
    public function render($view, array $parameters = [], Response $response = null)
    {
        $parameters = array_merge(
            $this->viewParameters,
            $parameters
        );

        return parent::render($view, $parameters, $response);
    }

    /**
     * Returns a JSON response
     *
     * @param mixed $data    The response data
     * @param int   $status  The response status code
     * @param array $headers An array of response headers
     * @return JsonResponse
     */
    public function renderJson($data = null, $status = 200, $headers = [])
    {
        return new JsonResponse($data, $status, $headers);
    }

    /**
     * Set the page title
     *
     * @param string $title Page title
     * @return $this
     */
    public function setTitle($title)
    {
        $this->viewParameters['title'] = $title;

        return $this;
    }
}
