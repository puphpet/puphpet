<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session\Session;
use Symfony\Component\Yaml\Yaml;

class FrontController extends Controller
{
    public function indexAction(Request $request)
    {
        $manager = $this->get('puphpet.extension.manager');

        /** @var Session $session */
        $session = $this->get('session');

        if ($request->isMethod('POST')) {
            $archive = $manager->createArchive($request->request->all());

            $response = new Response;
            $response->headers->set('Content-type', 'application/octet-stream');
            $response->headers->set('Content-Disposition', 'attachment; filename="puphpet.zip"');
            $response->setContent(file_get_contents($archive));

            return $response;
        }

        $messages = $session->getFlashBag()->all();

        return $this->render('PuphpetBundle:front:template.html.twig', [
            'extensions' => $manager->getExtensions(),
            'messages'   => $messages,
        ]);
    }

    public function uploadConfigAction(Request $request)
    {
        $config = $this->normalizeLineBreaks($request->get('config'));

        /** @var Session $session */
        $session = $this->get('session');

        try {
            $yaml = Yaml::parse($config);
        } catch (\Exception $e) {
            $session->getFlashBag()->add('error', [
                'title'   => 'There was a problem parsing your config file',
                'content' => $e->getMessage(),
            ]);

            $request->setMethod('GET');

            return $this->indexAction($request);
        }

        if (empty($yaml)) {
            $session->getFlashBag()->add('error', [
                'title'   => 'The config file provided was empty',
                'content' => 'Check your config file, or manually recreate it in the GUI.',
            ]);

            $request->setMethod('GET');

            return $this->indexAction($request);
        }

        $manager = $this->get('puphpet.extension.manager');
        $manager->setCustomDataAll($yaml);

        try {
            $session->getFlashBag()->add('success', [
                'title'   => 'Success!',
                'content' => 'Your previously generated config file was successfully loaded!',
            ]);

            $rendered = $this->render('PuphpetBundle:front:template.html.twig', [
                'extensions' => $manager->getExtensions(),
                'messages'   => $session->getFlashBag()->all(),
            ]);

            return $rendered;
        } catch (\Exception $e) {
            $session->getFlashBag()->clear();

            $session->getFlashBag()->add('error', [
                'title'   => 'There was a problem parsing your config file',
                'content' => sprintf(
                    '<p> Please recreate your manifest manually below.</p>' .
                    '<p>Error message:</p><p>%s</p>', $e->getMessage()
                )
            ]);

            return new RedirectResponse($this->generateUrl('puphpet.main.homepage'));
        }
    }

    public function generateArchiveAction(Request $request)
    {
        $config = $this->normalizeLineBreaks($request->get('config'));

        $values = '';

        try {
            $values = Yaml::parse($config);
        } catch (\Exception $e) {}

        if (empty($values)) {
            $response = new Response;
            $response->setStatusCode(Response::HTTP_NOT_ACCEPTABLE);

            return $response;
        }

        $manager = $this->get('puphpet.extension.manager');
        $archive = $manager->createArchive($values);

        $response = new Response;
        $response->headers->set('Content-type', 'application/octet-stream');
        $response->headers->set('Content-Disposition', sprintf('attachment; filename="%s"', 'puphpet.zip'));
        $response->setContent(file_get_contents($archive));

        return $response;
    }

    public function downloadPuppetModulesAction()
    {
        $manager = $this->get('puphpet.extension.manager');
        $archive = $manager->getPuppetModules();

        $response = new Response;
        $response->headers->set('Content-type', 'application/octet-stream');
        $response->headers->set('Content-Disposition', sprintf('attachment; filename="%s"', 'puphpet.zip'));
        $response->setContent(file_get_contents($archive));

        return $response;
    }

    public function aboutAction()
    {
        return $this->redirect('/#about');
    }

    public function helpAction()
    {
        return $this->redirect('/#help');
    }

    public function githubBtnAction()
    {
        if ($this->container->has('profiler')) {
            $this->container->get('profiler')->disable();
        }

        return $this->render('PuphpetBundle:front:github-btn.html.twig');
    }

    /**
     * Normalize linebreaks user-submitted text.
     *
     * @param string $config
     * @return string
     */
    private function normalizeLineBreaks($config)
    {
        $config = str_replace("\r\n", "\n", $config);
        $config = str_replace("\n\r", "\n", $config);

        $config = str_replace('\r\n', '\n', $config);
        $config = str_replace('\n\r', '\n', $config);

        return $config;
    }
}
